import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { authenticate, requireRole, type AuthUser } from './auth.js';
import type { Db } from './db.js';
import { forbidden, notFound } from './http.js';
import { seal } from './lib/key-box.js';
import { generateEventKeyPair } from './lib/ticket-token.js';

export const CATEGORIES = ['tech', 'music', 'sports', 'business', 'community'] as const;

export interface EventRow {
  id: string;
  organizer_id: string;
  title: string;
  description: string;
  category: (typeof CATEGORIES)[number];
  venue_name: string;
  latitude: number;
  longitude: number;
  geofence_radius_m: number;
  starts_at: Date;
  ends_at: Date;
  capacity: number;
  public_key: string;
  private_key_encrypted: string;
  /** Only present when the query counted the event's tickets. */
  issued?: number;
}

export const publicEvent = (e: EventRow) => ({
  id: e.id,
  title: e.title,
  description: e.description,
  category: e.category,
  venue: { name: e.venue_name, latitude: e.latitude, longitude: e.longitude, geofenceRadiusM: e.geofence_radius_m },
  startsAt: e.starts_at.toISOString(),
  endsAt: e.ends_at.toISOString(),
  capacity: e.capacity,
  ticketsIssued: e.issued,
});

const ISSUED = '(SELECT count(*)::int FROM tickets t WHERE t.event_id = events.id) AS issued';

export async function loadEvent(db: Db, id: string): Promise<EventRow> {
  if (!z.string().uuid().safeParse(id).success) throw notFound('Event');
  const { rows } = await db.query<EventRow>(`SELECT *, ${ISSUED} FROM events WHERE id = $1`, [id]);
  if (!rows[0]) throw notFound('Event');
  return rows[0];
}

export function assertOrganizer(event: EventRow, user: AuthUser): void {
  if (event.organizer_id !== user.sub) throw forbidden('Only the event organizer can do this');
}

/** Scanning is allowed for the event's organizer and anyone added as staff. */
export async function assertCanScan(db: Db, event: EventRow, user: AuthUser): Promise<void> {
  if (event.organizer_id === user.sub) return;
  const { rowCount } = await db.query('SELECT 1 FROM event_staff WHERE event_id = $1 AND user_id = $2', [
    event.id,
    user.sub,
  ]);
  if (!rowCount) throw forbidden('You are not staff for this event');
}

const createEventBody = z
  .object({
    title: z.string().trim().min(1).max(200),
    description: z.string().trim().max(2000).default(''),
    category: z.enum(CATEGORIES).default('tech'),
    venueName: z.string().trim().min(1).max(200),
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    geofenceRadiusM: z.number().int().min(10).max(5000).default(200),
    startsAt: z.coerce.date(),
    endsAt: z.coerce.date(),
    capacity: z.number().int().min(1).max(1_000_000),
  })
  .refine((b) => b.endsAt > b.startsAt, { message: 'endsAt must be after startsAt', path: ['endsAt'] });

const listQuery = z.object({
  q: z.string().trim().max(100).optional(),
  category: z.enum(CATEGORIES).optional(),
});

const addStaffBody = z.object({ email: z.string().email().transform((e) => e.toLowerCase()) });

export async function eventRoutes(app: FastifyInstance, { db, keyEncryptionKey }: { db: Db; keyEncryptionKey: Buffer }) {
  // Upcoming and ongoing events, optionally filtered by text and category.
  app.get('/events', async (request) => {
    const { q, category } = listQuery.parse(request.query);
    const { rows } = await db.query<EventRow>(
      `SELECT *, ${ISSUED} FROM events
       WHERE ends_at > now()
         AND ($1::text IS NULL OR title ILIKE '%' || $1 || '%' OR venue_name ILIKE '%' || $1 || '%')
         AND ($2::text IS NULL OR category = $2)
       ORDER BY starts_at LIMIT 100`,
      [q || null, category ?? null],
    );
    return rows.map(publicEvent);
  });

  app.get<{ Params: { id: string } }>('/events/:id', async (request) => {
    return publicEvent(await loadEvent(db, request.params.id));
  });

  app.post('/events', { preHandler: requireRole('organizer') }, async (request, reply) => {
    const body = createEventBody.parse(request.body);
    const { publicKeyPem, privateKeyPem } = generateEventKeyPair();
    const { rows } = await db.query<EventRow>(
      `INSERT INTO events (organizer_id, title, description, category, venue_name, latitude, longitude,
                           geofence_radius_m, starts_at, ends_at, capacity, public_key, private_key_encrypted)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
       RETURNING *, 0 AS issued`,
      [
        request.user.sub,
        body.title,
        body.description,
        body.category,
        body.venueName,
        body.latitude,
        body.longitude,
        body.geofenceRadiusM,
        body.startsAt,
        body.endsAt,
        body.capacity,
        publicKeyPem,
        seal(privateKeyPem, keyEncryptionKey),
      ],
    );
    return reply.status(201).send(publicEvent(rows[0]!));
  });

  // Events the signed-in user can scan tickets for: ones they organize or staff.
  app.get('/me/staff-events', { preHandler: authenticate }, async (request) => {
    const { rows } = await db.query<EventRow & { is_organizer: boolean }>(
      `SELECT *, ${ISSUED}, organizer_id = $1 AS is_organizer FROM events
       WHERE ends_at > now() - interval '1 day'
         AND (organizer_id = $1 OR id IN (SELECT event_id FROM event_staff WHERE user_id = $1))
       ORDER BY starts_at`,
      [request.user.sub],
    );
    return rows.map((e) => ({ ...publicEvent(e), role: e.is_organizer ? 'organizer' : 'staff' }));
  });

  // Admin dashboard: every event the organizer owns, past ones included, with live counts.
  app.get('/organizer/events', { preHandler: requireRole('organizer') }, async (request) => {
    const { rows } = await db.query<EventRow & { checked_in: number }>(
      `SELECT *, ${ISSUED},
              (SELECT count(*)::int FROM scans s WHERE s.event_id = events.id AND s.result = 'accepted') AS checked_in
       FROM events WHERE organizer_id = $1
       ORDER BY starts_at DESC`,
      [request.user.sub],
    );
    return rows.map((e) => ({ ...publicEvent(e), checkedIn: e.checked_in }));
  });

  app.get<{ Params: { id: string } }>('/events/:id/staff', { preHandler: authenticate }, async (request) => {
    const event = await loadEvent(db, request.params.id);
    assertOrganizer(event, request.user);
    const { rows } = await db.query<{ id: string; name: string; email: string; scans: number }>(
      `SELECT u.id, u.name, u.email,
              (SELECT count(*)::int FROM scans s WHERE s.event_id = $1 AND s.scanned_by = u.id) AS scans
       FROM event_staff es JOIN users u ON u.id = es.user_id
       WHERE es.event_id = $1 ORDER BY u.name`,
      [event.id],
    );
    return rows.map((r) => ({ userId: r.id, name: r.name, email: r.email, scans: r.scans }));
  });

  app.post<{ Params: { id: string } }>('/events/:id/staff', { preHandler: authenticate }, async (request, reply) => {
    const event = await loadEvent(db, request.params.id);
    assertOrganizer(event, request.user);
    const { email } = addStaffBody.parse(request.body);
    const { rows } = await db.query<{ id: string; name: string }>('SELECT id, name FROM users WHERE email = $1', [email]);
    const staff = rows[0];
    if (!staff) throw notFound('User with that email');
    await db.query('INSERT INTO event_staff (event_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [
      event.id,
      staff.id,
    ]);
    return reply.status(201).send({ userId: staff.id, name: staff.name, email });
  });

  app.delete<{ Params: { id: string; userId: string } }>(
    '/events/:id/staff/:userId',
    { preHandler: authenticate },
    async (request, reply) => {
      const event = await loadEvent(db, request.params.id);
      assertOrganizer(event, request.user);
      if (!z.string().uuid().safeParse(request.params.userId).success) throw notFound('Staff member');
      const { rowCount } = await db.query('DELETE FROM event_staff WHERE event_id = $1 AND user_id = $2', [
        event.id,
        request.params.userId,
      ]);
      if (!rowCount) throw notFound('Staff member');
      return reply.status(204).send();
    },
  );

  // Everything a scanner device needs to verify tickets with no connection.
  app.get<{ Params: { id: string } }>('/events/:id/scanner-bundle', { preHandler: authenticate }, async (request) => {
    const event = await loadEvent(db, request.params.id);
    await assertCanScan(db, event, request.user);
    const { rows } = await db.query<{ id: string }>(
      "SELECT id FROM tickets WHERE event_id = $1 AND status = 'revoked'",
      [event.id],
    );
    return {
      event: publicEvent(event),
      publicKey: event.public_key,
      revokedTicketIds: rows.map((r) => r.id),
      generatedAt: new Date().toISOString(),
    };
  });

  app.get<{ Params: { id: string } }>('/events/:id/stats', { preHandler: authenticate }, async (request) => {
    const event = await loadEvent(db, request.params.id);
    assertOrganizer(event, request.user);
    const [totals, timeline, devices] = await Promise.all([
      db.query<{ revoked: number; checked_in: number; rejected: number; qr: number; geofence: number }>(
        `SELECT
           count(*) FILTER (WHERE t.status = 'revoked')::int AS revoked,
           (SELECT count(*)::int FROM scans WHERE event_id = $1 AND result = 'accepted')                       AS checked_in,
           (SELECT count(*)::int FROM scans WHERE event_id = $1 AND result <> 'accepted')                      AS rejected,
           (SELECT count(*)::int FROM scans WHERE event_id = $1 AND result = 'accepted' AND method = 'qr')     AS qr,
           (SELECT count(*)::int FROM scans WHERE event_id = $1 AND result = 'accepted' AND method = 'geofence') AS geofence
         FROM tickets t WHERE t.event_id = $1`,
        [event.id],
      ),
      // Check-ins per 15 minutes, aligned to the event's start time.
      db.query<{ at: Date; check_ins: number }>(
        `SELECT date_bin('15 minutes', scanned_at, $2::timestamptz) AS at, count(*)::int AS check_ins
         FROM scans WHERE event_id = $1 AND result = 'accepted'
         GROUP BY 1 ORDER BY 1`,
        [event.id, event.starts_at],
      ),
      db.query<{ device_id: string; method: string; scans: number; accepted: number }>(
        `SELECT device_id, method, count(*)::int AS scans, count(*) FILTER (WHERE result = 'accepted')::int AS accepted
         FROM scans WHERE event_id = $1
         GROUP BY device_id, method ORDER BY scans DESC`,
        [event.id],
      ),
    ]);
    const s = totals.rows[0]!;
    return {
      capacity: event.capacity,
      issued: event.issued ?? 0,
      revoked: s.revoked,
      checkedIn: s.checked_in,
      rejectedScans: s.rejected,
      byMethod: { qr: s.qr, geofence: s.geofence },
      timeline: timeline.rows.map((r) => ({ at: r.at.toISOString(), checkIns: r.check_ins })),
      gates: devices.rows.map((r) => ({
        deviceId: r.method === 'geofence' ? 'Self check-in' : r.device_id,
        scans: r.scans,
        accepted: r.accepted,
      })),
    };
  });

  const ticketListQuery = z.object({
    q: z.string().trim().max(100).optional(),
    limit: z.coerce.number().int().min(1).max(500).default(200),
  });

  // Attendee list for the dashboard, with each ticket's check-in (if any).
  app.get<{ Params: { id: string } }>('/events/:id/tickets', { preHandler: authenticate }, async (request) => {
    const event = await loadEvent(db, request.params.id);
    assertOrganizer(event, request.user);
    const { q, limit } = ticketListQuery.parse(request.query);
    const { rows } = await db.query<{
      id: string;
      status: string;
      issued_at: Date;
      name: string;
      email: string;
      checked_in_at: Date | null;
      method: string | null;
    }>(
      `SELECT t.id, t.status, t.issued_at, u.name, u.email, s.scanned_at AS checked_in_at, s.method
       FROM tickets t
       JOIN users u ON u.id = t.user_id
       LEFT JOIN scans s ON s.ticket_id = t.id AND s.result = 'accepted'
       WHERE t.event_id = $1 AND ($2::text IS NULL OR u.name ILIKE '%' || $2 || '%' OR u.email ILIKE '%' || $2 || '%')
       ORDER BY t.issued_at DESC LIMIT $3`,
      [event.id, q || null, limit],
    );
    return rows.map((r) => ({
      id: r.id,
      status: r.status,
      issuedAt: r.issued_at.toISOString(),
      holder: { name: r.name, email: r.email },
      checkedInAt: r.checked_in_at?.toISOString() ?? null,
      checkInMethod: r.method,
    }));
  });

  const scanListQuery = z.object({ limit: z.coerce.number().int().min(1).max(200).default(50) });

  // Live feed of the most recently synced scans, newest first.
  app.get<{ Params: { id: string } }>('/events/:id/scans', { preHandler: authenticate }, async (request) => {
    const event = await loadEvent(db, request.params.id);
    assertOrganizer(event, request.user);
    const { limit } = scanListQuery.parse(request.query);
    const { rows } = await db.query<{
      id: string;
      result: string;
      method: string;
      device_id: string;
      scanned_at: Date;
      synced_at: Date;
      distance_m: number | null;
      latitude: number | null;
      longitude: number | null;
      scanned_by: string;
      holder: string | null;
    }>(
      `SELECT s.id, s.result, s.method, s.device_id, s.scanned_at, s.synced_at, s.distance_m, s.latitude, s.longitude,
              staff.name AS scanned_by, holder.name AS holder
       FROM scans s
       JOIN users staff ON staff.id = s.scanned_by
       LEFT JOIN tickets t ON t.id = s.ticket_id
       LEFT JOIN users holder ON holder.id = t.user_id
       WHERE s.event_id = $1
       ORDER BY s.synced_at DESC, s.scanned_at DESC LIMIT $2`,
      [event.id, limit],
    );
    return rows.map((r) => ({
      id: r.id,
      result: r.result,
      method: r.method,
      deviceId: r.device_id,
      scannedAt: r.scanned_at.toISOString(),
      syncedAt: r.synced_at.toISOString(),
      distanceM: r.distance_m,
      location: r.latitude != null && r.longitude != null ? { latitude: r.latitude, longitude: r.longitude } : null,
      scannedBy: r.scanned_by,
      holderName: r.holder,
    }));
  });

  app.post<{ Params: { id: string; ticketId: string } }>(
    '/events/:id/tickets/:ticketId/revoke',
    { preHandler: authenticate },
    async (request) => {
      const event = await loadEvent(db, request.params.id);
      assertOrganizer(event, request.user);
      if (!z.string().uuid().safeParse(request.params.ticketId).success) throw notFound('Ticket');
      const { rowCount } = await db.query(
        "UPDATE tickets SET status = 'revoked' WHERE id = $1 AND event_id = $2",
        [request.params.ticketId, event.id],
      );
      if (!rowCount) throw notFound('Ticket');
      return { id: request.params.ticketId, status: 'revoked' };
    },
  );
}

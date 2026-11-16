import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { authenticate, requireRole, type AuthUser } from './auth.js';
import type { Db } from './db.js';
import { forbidden, notFound } from './http.js';
import { seal } from './lib/key-box.js';
import { generateEventKeyPair } from './lib/ticket-token.js';

export interface EventRow {
  id: string;
  organizer_id: string;
  title: string;
  venue_name: string;
  latitude: number;
  longitude: number;
  geofence_radius_m: number;
  starts_at: Date;
  ends_at: Date;
  capacity: number;
  public_key: string;
  private_key_encrypted: string;
}

export const publicEvent = (e: EventRow) => ({
  id: e.id,
  title: e.title,
  venue: { name: e.venue_name, latitude: e.latitude, longitude: e.longitude, geofenceRadiusM: e.geofence_radius_m },
  startsAt: e.starts_at.toISOString(),
  endsAt: e.ends_at.toISOString(),
  capacity: e.capacity,
});

export async function loadEvent(db: Db, id: string): Promise<EventRow> {
  if (!z.string().uuid().safeParse(id).success) throw notFound('Event');
  const { rows } = await db.query<EventRow>('SELECT * FROM events WHERE id = $1', [id]);
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
    venueName: z.string().trim().min(1).max(200),
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    geofenceRadiusM: z.number().int().min(10).max(5000).default(200),
    startsAt: z.coerce.date(),
    endsAt: z.coerce.date(),
    capacity: z.number().int().min(1).max(1_000_000),
  })
  .refine((b) => b.endsAt > b.startsAt, { message: 'endsAt must be after startsAt', path: ['endsAt'] });

const addStaffBody = z.object({ email: z.string().email().transform((e) => e.toLowerCase()) });

export async function eventRoutes(app: FastifyInstance, { db, keyEncryptionKey }: { db: Db; keyEncryptionKey: Buffer }) {
  app.get('/events', async () => {
    const { rows } = await db.query<EventRow>('SELECT * FROM events WHERE ends_at > now() ORDER BY starts_at LIMIT 100');
    return rows.map(publicEvent);
  });

  app.get<{ Params: { id: string } }>('/events/:id', async (request) => {
    return publicEvent(await loadEvent(db, request.params.id));
  });

  app.post('/events', { preHandler: requireRole('organizer') }, async (request, reply) => {
    const body = createEventBody.parse(request.body);
    const { publicKeyPem, privateKeyPem } = generateEventKeyPair();
    const { rows } = await db.query<EventRow>(
      `INSERT INTO events (organizer_id, title, venue_name, latitude, longitude, geofence_radius_m,
                           starts_at, ends_at, capacity, public_key, private_key_encrypted)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [
        request.user.sub,
        body.title,
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
    return reply.status(201).send({ userId: staff.id, name: staff.name });
  });

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
    const { rows } = await db.query<{ issued: number; revoked: number; checked_in: number; rejected: number }>(
      `SELECT
         (SELECT count(*)::int FROM tickets WHERE event_id = $1)                              AS issued,
         (SELECT count(*)::int FROM tickets WHERE event_id = $1 AND status = 'revoked')       AS revoked,
         (SELECT count(*)::int FROM scans   WHERE event_id = $1 AND result = 'accepted')      AS checked_in,
         (SELECT count(*)::int FROM scans   WHERE event_id = $1 AND result <> 'accepted')     AS rejected`,
      [event.id],
    );
    const s = rows[0]!;
    return { capacity: event.capacity, issued: s.issued, revoked: s.revoked, checkedIn: s.checked_in, rejectedScans: s.rejected };
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

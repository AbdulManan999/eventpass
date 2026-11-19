import { randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { authenticate } from './auth.js';
import { withTransaction, type Db } from './db.js';
import { loadEvent, publicEvent, type EventRow } from './events.js';
import { conflict, HttpError } from './http.js';
import { open } from './lib/key-box.js';
import { distanceMeters } from './lib/geo.js';
import { signTicket } from './lib/ticket-token.js';

interface TicketRow {
  id: string;
  event_id: string;
  status: 'valid' | 'revoked';
  issued_at: Date;
  holder_name: string;
  checked_in_at: Date | null;
  check_in_method: 'qr' | 'nfc' | 'geofence' | null;
}

/** Self check-in opens this long before the event starts. */
export const SELF_CHECK_IN_OPENS_BEFORE_MS = 2 * 3_600_000;
/** Fixes less precise than this are rejected rather than trusted. */
export const MAX_ACCURACY_M = 100;

const TICKET_COLUMNS = `t.id, t.event_id, t.status, t.issued_at, u.name AS holder_name,
       s.scanned_at AS checked_in_at, s.method AS check_in_method`;
const TICKET_JOINS = `JOIN users u ON u.id = t.user_id
       LEFT JOIN scans s ON s.ticket_id = t.id AND s.result = 'accepted'`;

const checkInBody = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  accuracyM: z.number().min(0).max(100_000),
  isMocked: z.boolean().default(false),
});

const formatDistance = (m: number) => (m >= 1000 ? `${(m / 1000).toFixed(1)} km` : `${Math.round(m)} m`);

export async function ticketRoutes(app: FastifyInstance, { db, keyEncryptionKey }: { db: Db; keyEncryptionKey: Buffer }) {
  const present = (ticket: TicketRow, event: EventRow) => ({
    id: ticket.id,
    status: ticket.status,
    issuedAt: ticket.issued_at.toISOString(),
    checkedInAt: ticket.checked_in_at?.toISOString() ?? null,
    checkInMethod: ticket.check_in_method,
    event: publicEvent(event),
    // Ed25519 is deterministic, so re-signing on every request yields the same QR code.
    token: signTicket(
      {
        tid: ticket.id,
        eid: event.id,
        name: ticket.holder_name,
        iat: Math.floor(ticket.issued_at.getTime() / 1000),
      },
      open(event.private_key_encrypted, keyEncryptionKey),
    ),
  });

  // Claim a ticket. Claiming again returns the ticket you already hold.
  app.post<{ Params: { id: string } }>('/events/:id/tickets', { preHandler: authenticate }, async (request, reply) => {
    const userId = request.user.sub;
    const event = await loadEvent(db, request.params.id);
    if (event.ends_at <= new Date()) throw conflict('event_ended', 'This event has already ended');

    const { ticket, created } = await withTransaction(db, async (tx) => {
      // Lock the event row so concurrent claims can't oversell capacity.
      await tx.query('SELECT 1 FROM events WHERE id = $1 FOR UPDATE', [event.id]);

      const existing = await tx.query<TicketRow>(
        `SELECT ${TICKET_COLUMNS} FROM tickets t ${TICKET_JOINS} WHERE t.event_id = $1 AND t.user_id = $2`,
        [event.id, userId],
      );
      if (existing.rows[0]) return { ticket: existing.rows[0], created: false };

      const { rows } = await tx.query<{ n: number }>('SELECT count(*)::int AS n FROM tickets WHERE event_id = $1', [
        event.id,
      ]);
      if (rows[0]!.n >= event.capacity) throw conflict('sold_out', 'This event is at full capacity');

      const inserted = await tx.query<TicketRow>(
        `INSERT INTO tickets (event_id, user_id) VALUES ($1, $2)
         RETURNING id, event_id, status, issued_at, (SELECT name FROM users WHERE id = $2) AS holder_name,
                   NULL::timestamptz AS checked_in_at, NULL::text AS check_in_method`,
        [event.id, userId],
      );
      return { ticket: inserted.rows[0]!, created: true };
    });

    const issued = (event.issued ?? 0) + (created ? 1 : 0);
    return reply.status(created ? 201 : 200).send(present(ticket, { ...event, issued }));
  });

  app.get('/me/tickets', { preHandler: authenticate }, async (request) => {
    const { rows } = await db.query<TicketRow & { event: EventRow }>(
      `SELECT ${TICKET_COLUMNS}, to_jsonb(e) AS event
       FROM tickets t
       ${TICKET_JOINS}
       JOIN events e ON e.id = t.event_id
       WHERE t.user_id = $1
       ORDER BY e.starts_at`,
      [request.user.sub],
    );
    return rows.map((r) =>
      present(r, { ...r.event, starts_at: new Date(r.event.starts_at), ends_at: new Date(r.event.ends_at) }),
    );
  });

  // Geofenced self check-in: an attendee standing inside the venue's radius can
  // check themselves in from their own phone, without queueing at a gate.
  // It shares the "one accepted scan per ticket" rule with QR scanning, so a
  // ticket can't be used twice no matter which method came first.
  app.post<{ Params: { id: string } }>('/events/:id/check-in', { preHandler: authenticate }, async (request, reply) => {
    const event = await loadEvent(db, request.params.id);
    const body = checkInBody.parse(request.body);

    const { rows } = await db.query<TicketRow>(
      `SELECT ${TICKET_COLUMNS} FROM tickets t ${TICKET_JOINS} WHERE t.event_id = $1 AND t.user_id = $2`,
      [event.id, request.user.sub],
    );
    const ticket = rows[0];
    if (!ticket) throw new HttpError(403, 'no_ticket', 'You need a ticket for this event');
    if (ticket.status === 'revoked') throw conflict('ticket_revoked', 'This ticket has been revoked');
    if (ticket.checked_in_at) {
      return { status: 'already_checked_in', checkedInAt: ticket.checked_in_at.toISOString(), method: ticket.check_in_method };
    }

    const now = Date.now();
    if (now < event.starts_at.getTime() - SELF_CHECK_IN_OPENS_BEFORE_MS) {
      throw conflict('too_early', 'Self check-in opens 2 hours before the event starts');
    }
    if (now > event.ends_at.getTime()) throw conflict('event_ended', 'This event has already ended');
    if (body.isMocked) {
      throw new HttpError(422, 'mock_location', 'Turn off mock location apps to check in with your location');
    }
    if (body.accuracyM > MAX_ACCURACY_M) {
      throw new HttpError(422, 'location_imprecise', 'Your location is not precise enough. Move outdoors or enable precise location', {
        accuracyM: Math.round(body.accuracyM),
      });
    }

    const distanceM = Math.round(distanceMeters(body.latitude, body.longitude, event.latitude, event.longitude));
    if (distanceM > event.geofence_radius_m) {
      throw new HttpError(
        422,
        'outside_geofence',
        `You're ${formatDistance(distanceM)} from the venue. Self check-in works within ${formatDistance(event.geofence_radius_m)}`,
        { distanceM, radiusM: event.geofence_radius_m },
      );
    }

    const checkedInAt = new Date(now);
    const inserted = await db.query(
      `INSERT INTO scans (id, event_id, ticket_id, scanned_by, device_id, scanned_at, result, method, latitude, longitude, distance_m)
       VALUES ($1, $2, $3, $4, 'self', $5, 'accepted', 'geofence', $6, $7, $8)
       ON CONFLICT (ticket_id) WHERE result = 'accepted' DO NOTHING`,
      [randomUUID(), event.id, ticket.id, request.user.sub, checkedInAt, body.latitude, body.longitude, distanceM],
    );
    if (!inserted.rowCount) {
      // A gate scan for this ticket was synced between our read and our insert.
      const { rows: won } = await db.query<{ scanned_at: Date; method: string }>(
        "SELECT scanned_at, method FROM scans WHERE ticket_id = $1 AND result = 'accepted'",
        [ticket.id],
      );
      return { status: 'already_checked_in', checkedInAt: won[0]!.scanned_at.toISOString(), method: won[0]!.method };
    }
    return reply.status(201).send({ status: 'checked_in', checkedInAt: checkedInAt.toISOString(), method: 'geofence', distanceM });
  });
}

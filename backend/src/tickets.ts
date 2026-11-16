import type { FastifyInstance } from 'fastify';
import { authenticate } from './auth.js';
import { withTransaction, type Db } from './db.js';
import { loadEvent, publicEvent, type EventRow } from './events.js';
import { conflict } from './http.js';
import { open } from './lib/key-box.js';
import { signTicket } from './lib/ticket-token.js';

interface TicketRow {
  id: string;
  event_id: string;
  status: 'valid' | 'revoked';
  issued_at: Date;
  holder_name: string;
}

export async function ticketRoutes(app: FastifyInstance, { db, keyEncryptionKey }: { db: Db; keyEncryptionKey: Buffer }) {
  const present = (ticket: TicketRow, event: EventRow) => ({
    id: ticket.id,
    status: ticket.status,
    issuedAt: ticket.issued_at.toISOString(),
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
        `SELECT t.id, t.event_id, t.status, t.issued_at, u.name AS holder_name
         FROM tickets t JOIN users u ON u.id = t.user_id
         WHERE t.event_id = $1 AND t.user_id = $2`,
        [event.id, userId],
      );
      if (existing.rows[0]) return { ticket: existing.rows[0], created: false };

      const { rows } = await tx.query<{ n: number }>('SELECT count(*)::int AS n FROM tickets WHERE event_id = $1', [
        event.id,
      ]);
      if (rows[0]!.n >= event.capacity) throw conflict('sold_out', 'This event is at full capacity');

      const inserted = await tx.query<TicketRow>(
        `INSERT INTO tickets (event_id, user_id) VALUES ($1, $2)
         RETURNING id, event_id, status, issued_at, (SELECT name FROM users WHERE id = $2) AS holder_name`,
        [event.id, userId],
      );
      return { ticket: inserted.rows[0]!, created: true };
    });

    return reply.status(created ? 201 : 200).send(present(ticket, event));
  });

  app.get('/me/tickets', { preHandler: authenticate }, async (request) => {
    const { rows } = await db.query<TicketRow & { event: EventRow }>(
      `SELECT t.id, t.event_id, t.status, t.issued_at, u.name AS holder_name, to_jsonb(e) AS event
       FROM tickets t
       JOIN users u ON u.id = t.user_id
       JOIN events e ON e.id = t.event_id
       WHERE t.user_id = $1
       ORDER BY e.starts_at`,
      [request.user.sub],
    );
    return rows.map((r) =>
      present(r, { ...r.event, starts_at: new Date(r.event.starts_at), ends_at: new Date(r.event.ends_at) }),
    );
  });
}

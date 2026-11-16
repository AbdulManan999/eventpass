import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { authenticate } from './auth.js';
import type { Db } from './db.js';
import { assertCanScan, loadEvent } from './events.js';
import { verifyTicket } from './lib/ticket-token.js';

export type ScanResult = 'accepted' | 'duplicate' | 'revoked' | 'invalid';

const syncBody = z.object({
  deviceId: z.string().trim().min(1).max(100),
  scans: z
    .array(
      z.object({
        id: z.string().uuid(),
        token: z.string().max(2000),
        scannedAt: z.coerce.date(),
      }),
    )
    .min(1)
    .max(500),
});

export async function scanRoutes(app: FastifyInstance, { db }: { db: Db }) {
  // Scanner devices check tickets offline, queue the scans, and upload them
  // here when they reconnect. The server is the source of truth: if the same
  // ticket was scanned at two gates, the first scan synced is accepted and
  // the rest are recorded as duplicates. Re-sending a scan id is safe and
  // returns the result stored the first time.
  app.post<{ Params: { id: string } }>('/events/:id/scans/sync', { preHandler: authenticate }, async (request) => {
    const event = await loadEvent(db, request.params.id);
    await assertCanScan(db, event, request.user);
    const body = syncBody.parse(request.body);
    const scans = [...body.scans].sort((a, b) => a.scannedAt.getTime() - b.scannedAt.getTime());

    const results: { id: string; result: ScanResult; ticketId: string | null; holderName: string | null }[] = [];
    for (const scan of scans) {
      const previous = await db.query<{ result: ScanResult; ticket_id: string | null }>(
        'SELECT result, ticket_id FROM scans WHERE id = $1 AND event_id = $2',
        [scan.id, event.id],
      );
      if (previous.rows[0]) {
        const { result, ticket_id } = previous.rows[0];
        results.push({ id: scan.id, result, ticketId: ticket_id, holderName: null });
        continue;
      }

      const verified = verifyTicket(scan.token, event.public_key);
      const claims = verified.ok && verified.claims.eid === event.id ? verified.claims : null;
      const ticket = claims
        ? (
            await db.query<{ id: string; status: string }>('SELECT id, status FROM tickets WHERE id = $1 AND event_id = $2', [
              claims.tid,
              event.id,
            ])
          ).rows[0]
        : undefined;

      let result: ScanResult;
      if (!ticket) result = 'invalid';
      else if (ticket.status === 'revoked') result = 'revoked';
      else {
        // The partial unique index allows only one accepted scan per ticket.
        const accepted = await db.query(
          `INSERT INTO scans (id, event_id, ticket_id, scanned_by, device_id, scanned_at, result)
           VALUES ($1, $2, $3, $4, $5, $6, 'accepted')
           ON CONFLICT (ticket_id) WHERE result = 'accepted' DO NOTHING`,
          [scan.id, event.id, ticket.id, request.user.sub, body.deviceId, scan.scannedAt],
        );
        if (accepted.rowCount) {
          results.push({ id: scan.id, result: 'accepted', ticketId: ticket.id, holderName: claims!.name });
          continue;
        }
        result = 'duplicate';
      }

      await db.query(
        `INSERT INTO scans (id, event_id, ticket_id, scanned_by, device_id, scanned_at, result)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         ON CONFLICT (id) DO NOTHING`,
        [scan.id, event.id, ticket?.id ?? null, request.user.sub, body.deviceId, scan.scannedAt, result],
      );
      results.push({ id: scan.id, result, ticketId: ticket?.id ?? null, holderName: claims?.name ?? null });
    }

    return { results };
  });
}

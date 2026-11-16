import 'dotenv/config';
import { randomBytes, randomUUID } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { buildApp } from '../src/app.js';
import { createDb, type Db } from '../src/db.js';
import { verifyTicket } from '../src/lib/ticket-token.js';
import { migrate } from '../scripts/migrate.js';

// End-to-end API tests against a real PostgreSQL database.
// Set DATABASE_URL_TEST to run them; the database is wiped first.
const databaseUrl = process.env.DATABASE_URL_TEST;

describe.skipIf(!databaseUrl)('EventPass API', () => {
  let app: FastifyInstance;
  let db: Db;

  beforeAll(async () => {
    const admin = new pg.Client({ connectionString: databaseUrl });
    await admin.connect();
    await admin.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;');
    await admin.end();
    await migrate(databaseUrl!, () => {});

    db = createDb(databaseUrl!);
    app = await buildApp(
      {
        PORT: 0,
        DATABASE_URL: databaseUrl!,
        JWT_SECRET: randomBytes(32).toString('hex'),
        KEY_ENCRYPTION_KEY: randomBytes(32).toString('base64'),
        CORS_ORIGIN: '*',
      },
      db,
    );
  });

  afterAll(async () => {
    await app?.close();
    await db?.end();
  });

  const call = async (method: 'GET' | 'POST', url: string, token?: string, payload?: object) => {
    const res = await app.inject({
      method,
      url,
      payload,
      headers: token ? { authorization: `Bearer ${token}` } : {},
    });
    return { status: res.statusCode, body: res.json() };
  };

  const register = async (name: string, role: 'attendee' | 'organizer' = 'attendee') => {
    const res = await call('POST', '/auth/register', undefined, {
      email: `${name.toLowerCase()}@example.com`,
      password: 'correct horse battery',
      name,
      role,
    });
    expect(res.status).toBe(201);
    return res.body.token as string;
  };

  const createEvent = async (organizerToken: string, capacity = 100, startsAt = new Date(Date.now() + 86_400_000)) => {
    const res = await call('POST', '/events', organizerToken, {
      title: 'Lahore Flutter Meetup',
      venueName: 'Arfa Software Technology Park',
      latitude: 31.4757,
      longitude: 74.3424,
      startsAt: startsAt.toISOString(),
      endsAt: new Date(startsAt.getTime() + 3 * 3_600_000).toISOString(),
      capacity,
    });
    expect(res.status).toBe(201);
    return res.body.id as string;
  };

  it('runs the full flow: ticket, offline verification, sync, stats', async () => {
    const organizer = await register('Organizer', 'organizer');
    const attendee = await register('Bilal');
    const gateStaff = await register('Gate');
    const eventId = await createEvent(organizer);

    const ticket = await call('POST', `/events/${eventId}/tickets`, attendee);
    expect(ticket.status).toBe(201);

    // Claiming twice returns the same ticket instead of a second one.
    const again = await call('POST', `/events/${eventId}/tickets`, attendee);
    expect(again.status).toBe(200);
    expect(again.body.id).toBe(ticket.body.id);
    expect(again.body.token).toBe(ticket.body.token);

    // Staff can't scan until the organizer adds them.
    expect((await call('GET', `/events/${eventId}/scanner-bundle`, gateStaff)).status).toBe(403);
    expect((await call('POST', `/events/${eventId}/staff`, organizer, { email: 'gate@example.com' })).status).toBe(201);

    // The scanner verifies the QR code locally with only the bundle's public key.
    const bundle = await call('GET', `/events/${eventId}/scanner-bundle`, gateStaff);
    expect(bundle.status).toBe(200);
    const offline = verifyTicket(ticket.body.token, bundle.body.publicKey);
    expect(offline).toMatchObject({ ok: true, claims: { tid: ticket.body.id, name: 'Bilal' } });

    // Two gates scan the same ticket offline; the earlier scan wins on sync.
    const gateA = { id: randomUUID(), token: ticket.body.token, scannedAt: '2026-01-01T10:00:00Z' };
    const gateB = { id: randomUUID(), token: ticket.body.token, scannedAt: '2026-01-01T10:05:00Z' };
    const forged = { id: randomUUID(), token: 'EP1.bm9wZQ.bm9wZQ', scannedAt: '2026-01-01T10:06:00Z' };
    const sync = await call('POST', `/events/${eventId}/scans/sync`, gateStaff, {
      deviceId: 'gate-1',
      scans: [gateB, forged, gateA],
    });
    expect(sync.status).toBe(200);
    const byId = Object.fromEntries(sync.body.results.map((r: { id: string; result: string }) => [r.id, r.result]));
    expect(byId).toEqual({ [gateA.id]: 'accepted', [gateB.id]: 'duplicate', [forged.id]: 'invalid' });

    // Re-uploading after a dropped connection doesn't create new scans.
    const retry = await call('POST', `/events/${eventId}/scans/sync`, gateStaff, { deviceId: 'gate-1', scans: [gateA] });
    expect(retry.body.results[0].result).toBe('accepted');

    const stats = await call('GET', `/events/${eventId}/stats`, organizer);
    expect(stats.body).toMatchObject({
      capacity: 100,
      issued: 1,
      revoked: 0,
      checkedIn: 1,
      rejectedScans: 2,
      byMethod: { qr: 1, geofence: 0 },
      gates: [{ deviceId: 'gate-1', scans: 3, accepted: 1 }],
    });
    expect(stats.body.timeline).toEqual([{ at: expect.any(String), checkIns: 1 }]);

    // The attendee sees the check-in on their ticket.
    const mine = await call('GET', '/me/tickets', attendee);
    expect(mine.body[0]).toMatchObject({ checkedInAt: '2026-01-01T10:00:00.000Z', checkInMethod: 'qr' });
  });

  it('rejects revoked tickets and lists them in the scanner bundle', async () => {
    const organizer = await register('Organizer2', 'organizer');
    const attendee = await register('Sara');
    const eventId = await createEvent(organizer);
    const ticket = await call('POST', `/events/${eventId}/tickets`, attendee);

    expect((await call('POST', `/events/${eventId}/tickets/${ticket.body.id}/revoke`, attendee)).status).toBe(403);
    expect((await call('POST', `/events/${eventId}/tickets/${ticket.body.id}/revoke`, organizer)).status).toBe(200);

    const bundle = await call('GET', `/events/${eventId}/scanner-bundle`, organizer);
    expect(bundle.body.revokedTicketIds).toEqual([ticket.body.id]);

    const sync = await call('POST', `/events/${eventId}/scans/sync`, organizer, {
      deviceId: 'gate-1',
      scans: [{ id: randomUUID(), token: ticket.body.token, scannedAt: new Date().toISOString() }],
    });
    expect(sync.body.results[0].result).toBe('revoked');
  });

  it('never sells more tickets than capacity, even under concurrent claims', async () => {
    const organizer = await register('Organizer3', 'organizer');
    const eventId = await createEvent(organizer, 3);
    const attendees = await Promise.all(Array.from({ length: 8 }, (_, i) => register(`Fan${i}`)));

    const results = await Promise.all(attendees.map((t) => call('POST', `/events/${eventId}/tickets`, t)));
    expect(results.filter((r) => r.status === 201)).toHaveLength(3);
    expect(results.filter((r) => r.status === 409).every((r) => r.body.error === 'sold_out')).toBe(true);
  });

  it('protects routes by role and validates input', async () => {
    const attendee = await register('Usman');
    expect((await call('GET', '/me')).status).toBe(401);
    expect((await call('POST', '/events', attendee, {})).status).toBe(403);

    const organizer = await register('Organizer4', 'organizer');
    const bad = await call('POST', '/events', organizer, { title: '' });
    expect(bad.status).toBe(400);
    expect(bad.body.error).toBe('validation_failed');

    expect((await call('GET', '/events/not-a-uuid')).status).toBe(404);
    expect((await call('POST', '/auth/login', undefined, { email: 'usman@example.com', password: 'wrong' })).status).toBe(401);
  });

  describe('geofenced self check-in', () => {
    // Arfa Software Technology Park, Lahore; the default geofence is 200 m.
    const venue = { latitude: 31.4757, longitude: 74.3424 };
    const inside = { latitude: 31.4766, longitude: 74.3424, accuracyM: 15 }; // ~100 m north
    const outside = { latitude: 31.5204, longitude: 74.3587, accuracyM: 15 }; // ~5 km away

    const setup = async (name: string, startsInMs: number) => {
      const organizer = await register(`${name}Org`, 'organizer');
      const attendee = await register(name);
      const eventId = await createEvent(organizer, 100, new Date(Date.now() + startsInMs));
      await call('POST', `/events/${eventId}/tickets`, attendee);
      return { organizer, attendee, eventId };
    };

    it('checks in an attendee inside the radius, once', async () => {
      const { organizer, attendee, eventId } = await setup('Hina', -30 * 60_000);

      const far = await call('POST', `/events/${eventId}/check-in`, attendee, outside);
      expect(far.status).toBe(422);
      expect(far.body).toMatchObject({ error: 'outside_geofence', radiusM: 200 });
      expect(far.body.distanceM).toBeGreaterThan(4000);

      const near = await call('POST', `/events/${eventId}/check-in`, attendee, inside);
      expect(near.status).toBe(201);
      expect(near.body).toMatchObject({ status: 'checked_in', method: 'geofence' });
      expect(near.body.distanceM).toBeLessThan(200);

      const again = await call('POST', `/events/${eventId}/check-in`, attendee, inside);
      expect(again.status).toBe(200);
      expect(again.body.status).toBe('already_checked_in');

      // A gate scan of the same ticket afterwards is a duplicate, not a second entry.
      const [ticket] = (await call('GET', '/me/tickets', attendee)).body;
      expect(ticket).toMatchObject({ checkInMethod: 'geofence' });
      const sync = await call('POST', `/events/${eventId}/scans/sync`, organizer, {
        deviceId: 'gate-1',
        scans: [{ id: randomUUID(), token: ticket.token, scannedAt: new Date().toISOString() }],
      });
      expect(sync.body.results[0].result).toBe('duplicate');

      const stats = await call('GET', `/events/${eventId}/stats`, organizer);
      expect(stats.body).toMatchObject({ checkedIn: 1, byMethod: { qr: 0, geofence: 1 } });
    });

    it('rejects check-ins that are too early, imprecise, mocked or without a ticket', async () => {
      const early = await setup('Ali', 5 * 3_600_000);
      const tooEarly = await call('POST', `/events/${early.eventId}/check-in`, early.attendee, { ...venue, accuracyM: 5 });
      expect(tooEarly.status).toBe(409);
      expect(tooEarly.body.error).toBe('too_early');

      const live = await setup('Zara', -10 * 60_000);
      const vague = await call('POST', `/events/${live.eventId}/check-in`, live.attendee, { ...venue, accuracyM: 900 });
      expect(vague.body.error).toBe('location_imprecise');
      const mocked = await call('POST', `/events/${live.eventId}/check-in`, live.attendee, { ...inside, isMocked: true });
      expect(mocked.body.error).toBe('mock_location');

      const stranger = await register('Stranger');
      const noTicket = await call('POST', `/events/${live.eventId}/check-in`, stranger, inside);
      expect(noTicket.status).toBe(403);
    });
  });

  it('gives organizers an attendee list, scan feed, staff list and their events', async () => {
    const organizer = await register('Boss', 'organizer');
    const otherOrganizer = await register('Rival', 'organizer');
    const staff = await register('Kamran');
    const eventId = await createEvent(organizer);
    const tickets = [];
    for (const name of ['Ayesha', 'Fahad']) {
      tickets.push((await call('POST', `/events/${eventId}/tickets`, await register(name))).body);
    }
    await call('POST', `/events/${eventId}/staff`, organizer, { email: 'kamran@example.com' });
    await call('POST', `/events/${eventId}/scans/sync`, staff, {
      deviceId: 'north-gate',
      scans: [{ id: randomUUID(), token: tickets[0].token, scannedAt: new Date().toISOString() }],
    });

    const list = await call('GET', `/events/${eventId}/tickets?q=ayesha`, organizer);
    expect(list.body).toEqual([
      expect.objectContaining({ holder: { name: 'Ayesha', email: 'ayesha@example.com' }, checkInMethod: 'qr' }),
    ]);
    const feed = await call('GET', `/events/${eventId}/scans`, organizer);
    expect(feed.body[0]).toMatchObject({ result: 'accepted', scannedBy: 'Kamran', holderName: 'Ayesha', deviceId: 'north-gate' });

    const staffList = await call('GET', `/events/${eventId}/staff`, organizer);
    expect(staffList.body).toEqual([expect.objectContaining({ name: 'Kamran', scans: 1 })]);
    expect((await call('GET', '/me/staff-events', staff)).body).toEqual([expect.objectContaining({ id: eventId, role: 'staff' })]);

    const mine = await call('GET', '/organizer/events', organizer);
    expect(mine.body).toEqual([expect.objectContaining({ id: eventId, ticketsIssued: 2, checkedIn: 1 })]);

    // Another organizer can't read this event's data.
    expect((await call('GET', `/events/${eventId}/tickets`, otherOrganizer)).status).toBe(403);
    expect((await call('GET', `/events/${eventId}/scans`, otherOrganizer)).status).toBe(403);

    const removed = await app.inject({
      method: 'DELETE',
      url: `/events/${eventId}/staff/${staffList.body[0].userId}`,
      headers: { authorization: `Bearer ${organizer}` },
    });
    expect(removed.statusCode).toBe(204);
    expect((await call('GET', `/events/${eventId}/scanner-bundle`, staff)).status).toBe(403);
  });
});

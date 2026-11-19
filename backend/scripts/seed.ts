import { randomUUID } from 'node:crypto';
import { buildApp } from '../src/app.js';
import { loadConfig } from '../src/config.js';
import { createDb } from '../src/db.js';

// Creates demo accounts, events, tickets and check-ins through the real API
// routes, so the app and the admin dashboard have something to show.
// Safe to re-run: existing accounts are reused and existing events skipped.
// `npm run seed -- --reset` first deletes the demo organizer's events.

const config = loadConfig();
const db = createDb(config.DATABASE_URL);
const app = await buildApp(config, db);
const PASSWORD = 'eventpass-demo';

async function api<T = any>(method: 'GET' | 'POST', url: string, token?: string, payload?: object): Promise<{ status: number; body: T }> {
  const res = await app.inject({ method, url, payload, headers: token ? { authorization: `Bearer ${token}` } : {} });
  return { status: res.statusCode, body: res.json() as T };
}

async function account(name: string, email: string, role: 'attendee' | 'organizer' = 'attendee'): Promise<string> {
  const reg = await api('POST', '/auth/register', undefined, { name, email, password: PASSWORD, role });
  if (reg.status === 201) return reg.body.token;
  const login = await api('POST', '/auth/login', undefined, { email, password: PASSWORD });
  if (login.status !== 200) throw new Error(`Could not sign in as ${email}: ${JSON.stringify(login.body)}`);
  return login.body.token;
}

const hoursFromNow = (h: number) => new Date(Date.now() + h * 3_600_000);
const atHour = (days: number, hour: number) => {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() + days);
  d.setUTCHours(hour, 0, 0, 0);
  return d;
};

const ARFA = { venueName: 'Arfa Software Technology Park, Lahore', latitude: 31.4757, longitude: 74.3424 };

const events = [
  {
    // Happening right now, so scanning, self check-in and the live dashboard can be tried immediately.
    title: 'Lahore Tech Conference 2026',
    description: 'A full day of talks on mobile, cloud and AI from engineers building products used by millions in Pakistan.',
    category: 'tech',
    ...ARFA,
    geofenceRadiusM: 250,
    startsAt: hoursFromNow(-1.5),
    endsAt: hoursFromNow(8), // the demo reseeds every 6 h; 2 h of slack for late scheduled runs
    capacity: 300,
    demoAttendees: 42,
  },
  {
    title: 'Lahore Flutter Meetup',
    description: 'Monthly meetup for Flutter developers: two short talks, live coding and networking over chai.',
    category: 'tech',
    ...ARFA,
    geofenceRadiusM: 200,
    startsAt: atHour(7, 13),
    endsAt: atHour(7, 16),
    capacity: 150,
    demoAttendees: 18,
  },
  {
    title: 'Offline-First Mobile Workshop',
    description: 'Hands-on workshop: local databases, sync queues and conflict resolution for apps that work without signal.',
    category: 'tech',
    venueName: 'NIC Lahore',
    latitude: 31.4698,
    longitude: 74.4098,
    geofenceRadiusM: 150,
    startsAt: atHour(14, 5),
    endsAt: atHour(14, 11),
    capacity: 40,
    demoAttendees: 37,
  },
  {
    title: 'Sufi Night at Alhamra',
    description: 'An evening of qawwali and Sufi poetry under the stars.',
    category: 'music',
    venueName: 'Alhamra Arts Council, Lahore',
    latitude: 31.5547,
    longitude: 74.3375,
    geofenceRadiusM: 200,
    startsAt: atHour(10, 14),
    endsAt: atHour(10, 18),
    capacity: 800,
    demoAttendees: 25,
  },
  {
    title: 'Lahore Marathon Expo',
    description: 'Collect your race kit, meet running clubs and attend the pre-race nutrition session.',
    category: 'sports',
    venueName: 'Gaddafi Stadium, Lahore',
    latitude: 31.5135,
    longitude: 74.3336,
    geofenceRadiusM: 400,
    startsAt: atHour(21, 4),
    endsAt: atHour(21, 12),
    capacity: 2000,
    demoAttendees: 12,
  },
  {
    title: 'Startup Pitch Night',
    description: 'Ten early-stage startups pitch to investors. Networking dinner afterwards.',
    category: 'business',
    venueName: 'LUMS, Lahore',
    latitude: 31.4706,
    longitude: 74.4093,
    geofenceRadiusM: 300,
    startsAt: atHour(30, 13),
    endsAt: atHour(30, 17),
    capacity: 250,
    demoAttendees: 9,
  },
] as const;

const FIRST = ['Ayesha', 'Bilal', 'Hina', 'Usman', 'Sara', 'Fahad', 'Zainab', 'Hamza', 'Mahnoor', 'Ali', 'Iqra', 'Saad', 'Noor', 'Omer', 'Rabia', 'Talha'];
const LAST = ['Khan', 'Ahmed', 'Malik', 'Butt', 'Sheikh', 'Qureshi', 'Raza', 'Chaudhry', 'Iqbal', 'Hussain'];

try {
  const organizer = await account('Demo Organizer', 'organizer@eventpass.dev', 'organizer');
  if (process.argv.includes('--reset')) {
    const { rowCount } = await db.query(
      "DELETE FROM events WHERE organizer_id = (SELECT id FROM users WHERE email = 'organizer@eventpass.dev')",
    );
    console.log(`deleted ${rowCount} demo events`);
  }
  const attendee = await account('Demo Attendee', 'attendee@eventpass.dev');
  const staff = await account('Demo Gate Staff', 'staff@eventpass.dev');

  console.log('creating demo attendees…');
  const crowd: string[] = [];
  for (let i = 0; i < 45; i++) {
    const name = `${FIRST[i % FIRST.length]} ${LAST[(i * 7) % LAST.length]}`;
    crowd.push(await account(name, `guest${i + 1}@eventpass.dev`));
  }

  const existing = await api<{ title: string }[]>('GET', '/organizer/events', organizer);
  const live = new Set(existing.body.filter((e: any) => new Date(e.endsAt) > new Date()).map((e) => e.title));

  for (const e of events) {
    if (live.has(e.title)) continue;
    const { demoAttendees, startsAt, endsAt, ...rest } = e;
    const created = await api('POST', '/events', organizer, {
      ...rest,
      startsAt: startsAt.toISOString(),
      endsAt: endsAt.toISOString(),
    });
    if (created.status !== 201) throw new Error(`Could not create "${e.title}": ${JSON.stringify(created.body)}`);
    const eventId = created.body.id as string;
    await api('POST', `/events/${eventId}/staff`, organizer, { email: 'staff@eventpass.dev' });

    const tokens: string[] = [];
    for (const guest of crowd.slice(0, demoAttendees)) {
      const ticket = await api('POST', `/events/${eventId}/tickets`, guest);
      tokens.push(ticket.body.token);
    }

    const isLive = startsAt < new Date();
    if (isLive) {
      // The demo attendee holds a ticket but is not checked in yet, so they can try it.
      await api('POST', `/events/${eventId}/tickets`, attendee);

      // About 70% of the crowd came through two gates over the last 90 minutes.
      const scans = tokens.slice(0, 30).map((token, i) => ({
        id: randomUUID(),
        token,
        scannedAt: new Date(startsAt.getTime() - 20 * 60_000 + i * 3.5 * 60_000 + Math.random() * 60_000).toISOString(),
        // Every third guest tapped an NFC wristband or their phone instead of showing the QR.
        method: i % 3 === 0 ? 'nfc' : 'qr',
      }));
      const half = Math.ceil(scans.length / 2);
      await api('POST', `/events/${eventId}/scans/sync`, staff, { deviceId: 'North gate', scans: scans.slice(0, half) });
      await api('POST', `/events/${eventId}/scans/sync`, organizer, {
        deviceId: 'South gate',
        scans: [
          ...scans.slice(half),
          // A screenshot shown twice, and a tampered QR code.
          { id: randomUUID(), token: tokens[3], scannedAt: new Date().toISOString() },
          { id: randomUUID(), token: `${tokens[5]!.slice(0, -4)}AAAA`, scannedAt: new Date().toISOString() },
        ],
      });

      // A few attendees used geofenced self check-in from the venue.
      for (const guest of crowd.slice(30, 36)) {
        await api('POST', `/events/${eventId}/check-in`, guest, {
          latitude: e.latitude + (Math.random() - 0.5) * 0.002,
          longitude: e.longitude + (Math.random() - 0.5) * 0.002,
          accuracyM: 8 + Math.random() * 20,
        });
      }
    } else if (e.title === 'Lahore Flutter Meetup') {
      await api('POST', `/events/${eventId}/tickets`, attendee);
    }
    console.log(`created event: ${e.title}`);
  }

  console.log('\nDemo accounts (password: eventpass-demo):');
  console.log('  attendee@eventpass.dev   — app: tickets, QR, geofence check-in');
  console.log('  staff@eventpass.dev      — app: gate scanner');
  console.log('  organizer@eventpass.dev  — admin dashboard (and scanner)');
} finally {
  await app.close();
  await db.end();
}

import { buildApp } from '../src/app.js';
import { loadConfig } from '../src/config.js';
import { createDb } from '../src/db.js';

// Creates a demo organizer, a demo attendee and a few upcoming events through
// the real API routes, so the app has something to show. Safe to re-run:
// existing accounts are reused by logging in.

const config = loadConfig();
const db = createDb(config.DATABASE_URL);
const app = await buildApp(config, db);

async function account(name: string, email: string, role: 'attendee' | 'organizer'): Promise<string> {
  const password = 'eventpass-demo';
  const reg = await app.inject({ method: 'POST', url: '/auth/register', payload: { name, email, password, role } });
  if (reg.statusCode === 201) return reg.json().token;
  const login = await app.inject({ method: 'POST', url: '/auth/login', payload: { email, password } });
  if (login.statusCode !== 200) throw new Error(`Could not sign in as ${email}: ${login.body}`);
  return login.json().token;
}

const inDays = (days: number, hour: number) => {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() + days);
  d.setUTCHours(hour, 0, 0, 0);
  return d;
};

const events = [
  { title: 'Lahore Flutter Meetup', venueName: 'Arfa Software Technology Park, Lahore', latitude: 31.4757, longitude: 74.3424, days: 7, hour: 13, hours: 3, capacity: 150 },
  { title: 'Offline-First Mobile Workshop', venueName: 'NIC Lahore', latitude: 31.4698, longitude: 74.4098, days: 14, hour: 10, hours: 6, capacity: 40 },
  { title: 'Pakistan Dev Summit', venueName: 'Expo Centre, Lahore', latitude: 31.4694, longitude: 74.2668, days: 30, hour: 5, hours: 9, capacity: 2000 },
];

try {
  const organizer = await account('Demo Organizer', 'organizer@eventpass.dev', 'organizer');
  await account('Demo Attendee', 'attendee@eventpass.dev', 'attendee');

  const existing = await app.inject({ method: 'GET', url: '/events' });
  const titles = new Set((existing.json() as { title: string }[]).map((e) => e.title));

  for (const e of events) {
    if (titles.has(e.title)) continue;
    const startsAt = inDays(e.days, e.hour);
    const res = await app.inject({
      method: 'POST',
      url: '/events',
      headers: { authorization: `Bearer ${organizer}` },
      payload: {
        title: e.title,
        venueName: e.venueName,
        latitude: e.latitude,
        longitude: e.longitude,
        startsAt: startsAt.toISOString(),
        endsAt: new Date(startsAt.getTime() + e.hours * 3_600_000).toISOString(),
        capacity: e.capacity,
      },
    });
    if (res.statusCode !== 201) throw new Error(`Could not create "${e.title}": ${res.body}`);
    console.log(`created event: ${e.title}`);
  }

  console.log('\nDemo accounts (password: eventpass-demo):');
  console.log('  attendee@eventpass.dev   — use this one in the app');
  console.log('  organizer@eventpass.dev');
} finally {
  await app.close();
  await db.end();
}

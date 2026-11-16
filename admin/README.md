# EventPass admin dashboard

React + TypeScript dashboard for organizers: create events on a map, then watch check-ins live.

```bash
npm install
cp .env.example .env   # optional: VITE_API_URL, defaults to http://localhost:3000
npm run dev            # http://localhost:5173
npm test && npm run build
```

Sign in as `organizer@eventpass.dev` / `eventpass-demo` after running `npm run seed` in the backend.

Stack: React 19, Vite, TanStack Query (5 s polling for live data), React Router, Recharts, Leaflet + OpenStreetMap, Tailwind CSS 4, Vitest, oxlint.

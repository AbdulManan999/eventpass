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

## Dark mode

- The System / Light / Dark switch is in the header (and on the sign-in page). The choice is saved in `localStorage`; System follows the OS live.
- An inline script in `index.html` sets `data-theme` before the first paint, so a dark-mode user never sees a white flash.
- `src/index.css` swaps the colour scales in dark mode (slate-50 becomes the darkest background, slate-900 the brightest text, pale tints become translucent glows), the way Radix Colors does. Components keep plain classes like `text-slate-500` and work in both themes without `dark:` on every element.
- Recharts and Leaflet take colours as props, so they read them from `useTheme().chart` (`src/lib/theme.ts`). Map tiles are inverted with a CSS filter.
- Switching uses the View Transitions API: the new theme is revealed in a circle growing from the switch. Browsers without it, or with reduced motion turned on, switch instantly.

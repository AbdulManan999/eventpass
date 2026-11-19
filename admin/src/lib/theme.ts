/** Theme the organizer picked: follow the OS, or force light or dark. */
export type ThemePreference = 'system' | 'light' | 'dark'
export type ResolvedTheme = 'light' | 'dark'

/** Also read by the inline script in index.html, so the first paint is already in the right theme. */
export const THEME_STORAGE_KEY = 'eventpass.theme'

export const THEME_PREFERENCES: readonly ThemePreference[] = ['system', 'light', 'dark']

export function parsePreference(value: string | null | undefined): ThemePreference {
  return value === 'light' || value === 'dark' ? value : 'system'
}

export function resolveTheme(preference: ThemePreference, systemPrefersDark: boolean): ResolvedTheme {
  if (preference === 'system') return systemPrefersDark ? 'dark' : 'light'
  return preference
}

/**
 * Radius of the circle that grows from the click point during the theme
 * switch: the distance to the farthest corner, so it covers the whole window.
 */
export function revealRadius(x: number, y: number, width: number, height: number): number {
  return Math.hypot(Math.max(x, width - x), Math.max(y, height - y))
}

/**
 * Colours for Recharts and Leaflet. They draw SVG/canvas with colour values
 * passed as props, so they can't follow the CSS variables and get them from here.
 */
export const CHART_THEME = {
  light: {
    grid: '#e2e8f0',
    tick: '#64748b',
    tooltipBg: '#ffffff',
    tooltipBorder: '#e2e8f0',
    tooltipText: '#1e293b',
    bar: '#A5B4FC',
    line: '#4338CA',
    empty: '#e2e8f0',
    methods: { qr: '#4338CA', nfc: '#D946EF', geofence: '#10B981' },
    venue: '#4338CA',
    venueFill: '#6366F1',
    markerRing: '#ffffff',
  },
  dark: {
    grid: '#2a3350',
    tick: '#8391ab',
    tooltipBg: '#1e2640',
    tooltipBorder: '#3a4566',
    tooltipText: '#e2e8f0',
    bar: '#4f46e5',
    line: '#a5b4fc',
    empty: '#2a3350',
    methods: { qr: '#818CF8', nfc: '#E879F9', geofence: '#34D399' },
    venue: '#a5b4fc',
    venueFill: '#818cf8',
    markerRing: '#151b2e',
  },
} as const

export type ChartTheme = (typeof CHART_THEME)[ResolvedTheme]

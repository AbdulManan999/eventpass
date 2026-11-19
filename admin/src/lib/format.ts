import type { Category } from '../api/types'

export type EventStatus = 'live' | 'upcoming' | 'ended'

export function eventStatus(startsAt: string, endsAt: string, now = Date.now()): EventStatus {
  if (now < Date.parse(startsAt)) return 'upcoming'
  if (now > Date.parse(endsAt)) return 'ended'
  return 'live'
}

const dateFmt = new Intl.DateTimeFormat('en-GB', { weekday: 'short', day: 'numeric', month: 'short' })
const timeFmt = new Intl.DateTimeFormat('en-GB', { hour: '2-digit', minute: '2-digit' })

export const formatDate = (iso: string) => dateFmt.format(new Date(iso))
export const formatTime = (iso: string) => timeFmt.format(new Date(iso))
export const formatDateTime = (iso: string) => `${formatDate(iso)}, ${formatTime(iso)}`

export function formatDistance(m: number): string {
  return m >= 1000 ? `${(m / 1000).toFixed(1)} km` : `${Math.round(m)} m`
}

export function percent(part: number, whole: number): number {
  return whole > 0 ? Math.round((part / whole) * 100) : 0
}

export function timeAgo(iso: string, now = Date.now()): string {
  const s = Math.max(0, Math.round((now - Date.parse(iso)) / 1000))
  if (s < 60) return `${s}s ago`
  if (s < 3600) return `${Math.floor(s / 60)}m ago`
  if (s < 86_400) return `${Math.floor(s / 3600)}h ago`
  return `${Math.floor(s / 86_400)}d ago`
}

export const BUCKET_MS = 15 * 60_000

export interface TimelinePoint {
  at: number
  label: string
  checkIns: number
  total: number
}

/**
 * Turns the API's sparse 15-minute buckets into a continuous series for the
 * chart: empty buckets become zeros, and `total` is the running check-in count.
 * The series runs from the first bucket (or the event start) up to now, or the
 * event end if it is over.
 */
export function fillTimeline(
  buckets: { at: string; checkIns: number }[],
  startsAt: string,
  endsAt: string,
  now = Date.now(),
): TimelinePoint[] {
  const byTime = new Map(buckets.map((b) => [Date.parse(b.at), b.checkIns]))
  const eventStart = Date.parse(startsAt)
  const first = Math.min(eventStart, ...byTime.keys())
  const last = Math.max(Math.min(now, Date.parse(endsAt)), ...byTime.keys())
  if (last < first) return []

  const points: TimelinePoint[] = []
  let total = 0
  for (let t = first; t <= last; t += BUCKET_MS) {
    const checkIns = byTime.get(t) ?? 0
    total += checkIns
    points.push({ at: t, label: formatTime(new Date(t).toISOString()), checkIns, total })
  }
  return points
}

const category = (label: string, solid: string, key: Category) => ({
  label,
  /** Fills behind white text (selected chip, card stripe): the same in both themes. */
  solid,
  /** Text and its tinted background; lighter in dark mode (variables in index.css). */
  color: `var(--cat-${key})`,
  bg: `color-mix(in oklab, var(--cat-${key}) var(--cat-bg-alpha), transparent)`,
})

export const CATEGORY_STYLE: Record<Category, { label: string; solid: string; color: string; bg: string }> = {
  tech: category('Tech', '#4338CA', 'tech'),
  music: category('Music', '#BE185D', 'music'),
  sports: category('Sports', '#047857', 'sports'),
  business: category('Business', '#B45309', 'business'),
  community: category('Community', '#0369A1', 'community'),
}

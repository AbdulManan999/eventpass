import { CalendarDays, MapPin, Plus } from 'lucide-react'
import { Link } from 'react-router'
import { useMyEvents } from '../api/hooks'
import type { EventSummary } from '../api/types'
import { CategoryBadge, EmptyState, ErrorNote, ProgressBar, Spinner, StatusBadge } from '../components/ui'
import { CATEGORY_STYLE, eventStatus, formatDateTime, percent, type EventStatus } from '../lib/format'

const ORDER: Record<EventStatus, number> = { live: 0, upcoming: 1, ended: 2 }

export function EventsPage() {
  const { data, isPending, error } = useMyEvents()

  const events = [...(data ?? [])].sort((a, b) => {
    const s = ORDER[eventStatus(a.startsAt, a.endsAt)] - ORDER[eventStatus(b.startsAt, b.endsAt)]
    return s !== 0 ? s : Date.parse(a.startsAt) - Date.parse(b.startsAt)
  })
  const totals = (data ?? []).reduce(
    (t, e) => ({ issued: t.issued + e.ticketsIssued, checkedIn: t.checkedIn + e.checkedIn }),
    { issued: 0, checkedIn: 0 },
  )
  const liveCount = events.filter((e) => eventStatus(e.startsAt, e.endsAt) === 'live').length

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Your events</h1>
          {data && (
            <p className="mt-1 text-sm text-slate-500">
              {data.length} events · {liveCount} live now · {totals.issued.toLocaleString()} tickets issued ·{' '}
              {totals.checkedIn.toLocaleString()} checked in
            </p>
          )}
        </div>
        <Link to="/events/new" className="btn-primary">
          <Plus size={16} /> New event
        </Link>
      </div>

      <ErrorNote error={error} />
      {isPending && <Spinner className="mx-auto mt-10" />}

      {data && data.length === 0 && (
        <div className="card">
          <EmptyState icon={<CalendarDays size={40} />} title="No events yet">
            <Link to="/events/new" className="btn-primary mt-2">Create your first event</Link>
          </EmptyState>
        </div>
      )}

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {events.map((e) => (
          <EventCard key={e.id} event={e} />
        ))}
      </div>
    </div>
  )
}

function EventCard({ event: e }: { event: EventSummary }) {
  const status = eventStatus(e.startsAt, e.endsAt)
  return (
    <Link
      to={`/events/${e.id}`}
      className="card group flex flex-col overflow-hidden transition hover:-translate-y-0.5 hover:shadow-lg hover:shadow-slate-200"
    >
      <div className="h-1.5" style={{ background: CATEGORY_STYLE[e.category].color }} />
      <div className="flex flex-1 flex-col gap-4 p-5">
        <div className="flex items-center gap-2">
          <StatusBadge status={status} />
          <CategoryBadge category={e.category} />
        </div>
        <div>
          <h3 className="font-semibold text-slate-900 group-hover:text-brand-700">{e.title}</h3>
          <p className="mt-1 flex items-center gap-1.5 text-sm text-slate-500">
            <CalendarDays size={14} /> {formatDateTime(e.startsAt)}
          </p>
          <p className="mt-0.5 flex items-center gap-1.5 text-sm text-slate-500">
            <MapPin size={14} /> <span className="truncate">{e.venue.name}</span>
          </p>
        </div>
        <div className="mt-auto space-y-3">
          <div>
            <div className="mb-1 flex justify-between text-xs text-slate-500">
              <span>Tickets</span>
              <span className="font-medium text-slate-700">
                {e.ticketsIssued} / {e.capacity}
              </span>
            </div>
            <ProgressBar value={e.ticketsIssued} max={e.capacity} />
          </div>
          <div>
            <div className="mb-1 flex justify-between text-xs text-slate-500">
              <span>Checked in</span>
              <span className="font-medium text-slate-700">
                {e.checkedIn} · {percent(e.checkedIn, e.ticketsIssued)}%
              </span>
            </div>
            <ProgressBar value={e.checkedIn} max={e.ticketsIssued} color="bg-emerald-500" />
          </div>
        </div>
      </div>
    </Link>
  )
}

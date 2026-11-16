import { ArrowLeft, CalendarDays, CheckCircle2, MapPin, ShieldAlert, Ticket, Users } from 'lucide-react'
import type { ReactNode } from 'react'
import { Link, useParams } from 'react-router'
import { useEvent, useScans, useStats } from '../api/hooks'
import { CheckInChart, MethodDonut } from '../components/dashboard/Charts'
import { AttendeesTable } from '../components/dashboard/AttendeesTable'
import { GatesPanel } from '../components/dashboard/GatesPanel'
import { ScanFeed } from '../components/dashboard/ScanFeed'
import { StaffPanel } from '../components/dashboard/StaffPanel'
import { Card, CategoryBadge, ErrorNote, ProgressBar, Spinner, StatusBadge } from '../components/ui'
import { VenueMap } from '../components/VenueMap'
import { eventStatus, formatDateTime, formatDistance, formatTime, percent } from '../lib/format'

export function EventDashboardPage() {
  const { id = '' } = useParams()
  const event = useEvent(id)
  const stats = useStats(id)
  const scans = useScans(id)

  if (event.error) return <ErrorNote error={event.error} />
  if (!event.data) return <Spinner className="mx-auto mt-10" />

  const e = event.data
  const s = stats.data
  const status = eventStatus(e.startsAt, e.endsAt)
  const selfCheckIns = (scans.data ?? [])
    .filter((x) => x.method === 'geofence' && x.location)
    .map((x) => ({
      id: x.id,
      latitude: x.location!.latitude,
      longitude: x.location!.longitude,
      label: `${x.holderName ?? 'Attendee'} · ${x.distanceM != null ? formatDistance(x.distanceM) : ''} · ${formatTime(x.scannedAt)}`,
    }))

  return (
    <div className="space-y-6">
      <div>
        <Link to="/" className="inline-flex items-center gap-1 text-sm text-slate-500 hover:text-brand-700">
          <ArrowLeft size={14} /> All events
        </Link>
        <div className="mt-2 flex flex-wrap items-center gap-3">
          <h1 className="text-2xl font-bold text-slate-900">{e.title}</h1>
          <StatusBadge status={status} />
          <CategoryBadge category={e.category} />
        </div>
        <div className="mt-1 flex flex-wrap gap-x-4 gap-y-1 text-sm text-slate-500">
          <span className="flex items-center gap-1.5">
            <CalendarDays size={14} /> {formatDateTime(e.startsAt)} – {formatTime(e.endsAt)}
          </span>
          <span className="flex items-center gap-1.5">
            <MapPin size={14} /> {e.venue.name}
          </span>
          {status === 'live' && <span className="text-emerald-600">Refreshing every 5 seconds</span>}
        </div>
      </div>

      <ErrorNote error={stats.error} />

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <StatCard icon={<Ticket size={18} />} label="Tickets issued" value={s?.issued} sub={s && `of ${s.capacity} · ${percent(s.issued, s.capacity)}% sold`}>
          {s && <ProgressBar value={s.issued} max={s.capacity} />}
        </StatCard>
        <StatCard icon={<CheckCircle2 size={18} />} label="Checked in" value={s?.checkedIn} sub={s && `${percent(s.checkedIn, s.issued - s.revoked)}% of valid tickets`} tone="emerald">
          {s && <ProgressBar value={s.checkedIn} max={s.issued - s.revoked} color="bg-emerald-500" />}
        </StatCard>
        <StatCard icon={<Users size={18} />} label="Still to arrive" value={s && Math.max(0, s.issued - s.revoked - s.checkedIn)} sub={s && `${s.revoked} tickets revoked`} tone="amber" />
        <StatCard icon={<ShieldAlert size={18} />} label="Rejected scans" value={s?.rejectedScans} sub="duplicates, revoked or forged" tone="rose" />
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="Check-ins over time" className="lg:col-span-2">
          {s ? <CheckInChart stats={s} startsAt={e.startsAt} endsAt={e.endsAt} /> : <Spinner />}
        </Card>
        <Card title="How people checked in">
          {s ? <MethodDonut byMethod={s.byMethod} /> : <Spinner />}
          {s && <GatesPanel gates={s.gates} />}
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="Live scan feed" className="lg:col-span-2">
          <ScanFeed scans={scans.data} />
        </Card>
        <Card title="Geofence">
          <VenueMap latitude={e.venue.latitude} longitude={e.venue.longitude} radiusM={e.venue.geofenceRadiusM} points={selfCheckIns} />
          <p className="mt-3 text-sm text-slate-500">
            Self check-in radius <span className="font-medium text-slate-700">{formatDistance(e.venue.geofenceRadiusM)}</span>. Green
            dots are recent self check-ins.
          </p>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="Attendees" className="lg:col-span-2">
          <AttendeesTable eventId={id} />
        </Card>
        <Card title="Gate staff">
          <StaffPanel eventId={id} />
        </Card>
      </div>
    </div>
  )
}

const TONES = {
  brand: 'bg-brand-50 text-brand-700',
  emerald: 'bg-emerald-50 text-emerald-700',
  amber: 'bg-amber-50 text-amber-700',
  rose: 'bg-rose-50 text-rose-700',
}

function StatCard({
  icon,
  label,
  value,
  sub,
  tone = 'brand',
  children,
}: {
  icon: ReactNode
  label: string
  value: number | undefined
  sub?: ReactNode
  tone?: keyof typeof TONES
  children?: ReactNode
}) {
  return (
    <div className="card space-y-3 p-5">
      <div className="flex items-center gap-2 text-sm font-medium text-slate-500">
        <span className={`grid size-8 place-items-center rounded-lg ${TONES[tone]}`}>{icon}</span>
        {label}
      </div>
      <p className="text-3xl font-bold tabular-nums text-slate-900">{value?.toLocaleString() ?? '–'}</p>
      {children}
      {sub && <p className="text-xs text-slate-500">{sub}</p>}
    </div>
  )
}

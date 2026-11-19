import { Search, UserX } from 'lucide-react'
import { useEffect, useState } from 'react'
import { useAttendees, useRevokeTicket } from '../../api/hooks'
import type { AttendeeTicket } from '../../api/types'
import { formatDateTime, formatTime } from '../../lib/format'
import { EmptyState, ErrorNote, Spinner } from '../ui'

function useDebounced<T>(value: T, ms = 300): T {
  const [v, setV] = useState(value)
  useEffect(() => {
    const t = setTimeout(() => setV(value), ms)
    return () => clearTimeout(t)
  }, [value, ms])
  return v
}

type Filter = 'all' | 'in' | 'out' | 'revoked'

const matches = (t: AttendeeTicket, f: Filter) =>
  f === 'all' ||
  (f === 'in' && !!t.checkedInAt) ||
  (f === 'out' && !t.checkedInAt && t.status === 'valid') ||
  (f === 'revoked' && t.status === 'revoked')

export function AttendeesTable({ eventId }: { eventId: string }) {
  const [query, setQuery] = useState('')
  const [filter, setFilter] = useState<Filter>('all')
  const q = useDebounced(query.trim())
  const attendees = useAttendees(eventId, q)
  const revoke = useRevokeTicket(eventId)

  const rows = (attendees.data ?? []).filter((t) => matches(t, filter))
  const filters: { key: Filter; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'in', label: 'Checked in' },
    { key: 'out', label: 'Not arrived' },
    { key: 'revoked', label: 'Revoked' },
  ]

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center gap-2">
        <div className="relative min-w-48 flex-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input className="input pl-9" placeholder="Search name or email" value={query} onChange={(e) => setQuery(e.target.value)} />
        </div>
        <div className="flex rounded-lg bg-slate-100 p-1">
          {filters.map((f) => (
            <button
              key={f.key}
              type="button"
              onClick={() => setFilter(f.key)}
              className={`rounded-md px-2.5 py-1 text-xs font-medium transition ${
                filter === f.key ? 'bg-surface text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      <ErrorNote error={attendees.error ?? revoke.error} />
      {attendees.isPending && <Spinner />}
      {attendees.data && rows.length === 0 && <EmptyState icon={<UserX size={36} />} title="No attendees match" />}

      {rows.length > 0 && (
        <div className="max-h-[28rem] overflow-auto rounded-lg border border-slate-100">
          <table className="w-full text-left text-sm">
            <thead className="sticky top-0 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-3 py-2 font-medium">Attendee</th>
                <th className="hidden px-3 py-2 font-medium sm:table-cell">Ticket issued</th>
                <th className="px-3 py-2 font-medium">Status</th>
                <th className="px-3 py-2" />
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {rows.map((t) => (
                <tr key={t.id} className="hover:bg-slate-50/60">
                  <td className="px-3 py-2.5">
                    <p className="font-medium text-slate-900">{t.holder.name}</p>
                    <p className="text-xs text-slate-500">{t.holder.email}</p>
                  </td>
                  <td className="hidden px-3 py-2.5 text-slate-500 sm:table-cell">{formatDateTime(t.issuedAt)}</td>
                  <td className="px-3 py-2.5">
                    <AttendeeStatus ticket={t} />
                  </td>
                  <td className="px-3 py-2.5 text-right">
                    {t.status === 'valid' && (
                      <button
                        type="button"
                        className="rounded-md px-2 py-1 text-xs font-medium text-rose-600 hover:bg-rose-50 disabled:opacity-50"
                        disabled={revoke.isPending}
                        onClick={() => {
                          if (confirm(`Revoke ${t.holder.name}'s ticket? Gate phones reject it after their next sync.`)) revoke.mutate(t.id)
                        }}
                      >
                        Revoke
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      {attendees.data && (
        <p className="text-xs text-slate-400">
          Showing {rows.length} of {attendees.data.length}
        </p>
      )}
    </div>
  )
}

function AttendeeStatus({ ticket: t }: { ticket: AttendeeTicket }) {
  if (t.status === 'revoked') return <span className="rounded-full bg-rose-50 px-2 py-0.5 text-xs font-semibold text-rose-700">Revoked</span>
  if (t.checkedInAt) {
    return (
      <span className="rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-semibold text-emerald-700">
        In · {formatTime(t.checkedInAt)} · {t.checkInMethod === 'geofence' ? 'Geofence' : t.checkInMethod === 'nfc' ? 'NFC' : 'QR'}
      </span>
    )
  }
  return <span className="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-semibold text-slate-500">Not arrived</span>
}

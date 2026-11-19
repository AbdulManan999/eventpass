import { CheckCircle2, Copy, MapPin, Nfc, ScanLine, ShieldX, XCircle } from 'lucide-react'
import type { Scan, ScanResult } from '../../api/types'
import { formatDistance, formatTime, timeAgo } from '../../lib/format'
import { EmptyState, Spinner } from '../ui'

const RESULT: Record<ScanResult, { label: string; icon: typeof CheckCircle2; className: string }> = {
  accepted: { label: 'Admitted', icon: CheckCircle2, className: 'bg-emerald-50 text-emerald-700' },
  duplicate: { label: 'Already used', icon: Copy, className: 'bg-amber-50 text-amber-700' },
  revoked: { label: 'Revoked', icon: ShieldX, className: 'bg-rose-50 text-rose-700' },
  invalid: { label: 'Forged / invalid', icon: XCircle, className: 'bg-rose-50 text-rose-700' },
}

export function ScanFeed({ scans }: { scans: Scan[] | undefined }) {
  if (!scans) return <Spinner />
  if (scans.length === 0) {
    return (
      <EmptyState icon={<ScanLine size={40} />} title="No scans yet">
        <p className="text-sm">Scans appear here as soon as a gate phone syncs.</p>
      </EmptyState>
    )
  }
  return (
    <ul className="max-h-[26rem] divide-y divide-slate-100 overflow-y-auto pr-1">
      {scans.map((s) => {
        const r = RESULT[s.result]
        const Icon = r.icon
        // Scans made offline arrive later; show how long the device waited to sync.
        const delayMin = Math.round((Date.parse(s.syncedAt) - Date.parse(s.scannedAt)) / 60_000)
        return (
          <li key={s.id} className="flex items-center gap-3 py-2.5">
            <span className={`grid size-9 shrink-0 place-items-center rounded-full ${r.className}`}>
              {s.method === 'geofence' ? <MapPin size={16} /> : s.method === 'nfc' ? <Nfc size={16} /> : <Icon size={16} />}
            </span>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-medium text-slate-900">{s.holderName ?? 'Unknown ticket'}</p>
              <p className="truncate text-xs text-slate-500">
                {s.method === 'geofence'
                  ? `Self check-in${s.distanceM != null ? ` · ${formatDistance(s.distanceM)} from venue` : ''}`
                  : `${s.deviceId} · ${s.method === 'nfc' ? 'NFC tap · ' : ''}${s.scannedBy}`}
                {delayMin >= 2 && ` · synced ${delayMin} min after scan (offline)`}
              </p>
            </div>
            <div className="text-right">
              <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${r.className}`}>{r.label}</span>
              <p className="mt-1 text-xs text-slate-400" title={s.scannedAt}>
                {formatTime(s.scannedAt)} · {timeAgo(s.scannedAt)}
              </p>
            </div>
          </li>
        )
      })}
    </ul>
  )
}

import { DoorOpen, Smartphone } from 'lucide-react'
import type { Stats } from '../../api/types'
import { ProgressBar } from '../ui'

export function GatesPanel({ gates }: { gates: Stats['gates'] }) {
  if (gates.length === 0) return null
  const max = Math.max(...gates.map((g) => g.scans))
  return (
    <div className="mt-6 border-t border-slate-100 pt-4">
      <h3 className="mb-3 text-sm font-semibold text-slate-700">By gate</h3>
      <ul className="space-y-3">
        {gates.map((g) => {
          const self = g.deviceId === 'Self check-in'
          return (
            <li key={g.deviceId}>
              <div className="mb-1 flex items-center justify-between text-sm">
                <span className="flex items-center gap-1.5 text-slate-600">
                  {self ? <Smartphone size={14} /> : <DoorOpen size={14} />}
                  {g.deviceId}
                </span>
                <span className="tabular-nums text-slate-500">
                  <span className="font-semibold text-slate-900">{g.accepted}</span> / {g.scans} scans
                </span>
              </div>
              <ProgressBar value={g.scans} max={max} color={self ? 'bg-emerald-500' : 'bg-brand-600'} />
            </li>
          )
        })}
      </ul>
    </div>
  )
}

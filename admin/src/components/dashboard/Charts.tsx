import { Bar, CartesianGrid, Cell, ComposedChart, Line, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import type { Stats } from '../../api/types'
import { fillTimeline } from '../../lib/format'
import { EmptyState } from '../ui'
import { BarChart3 } from 'lucide-react'

export function CheckInChart({ stats, startsAt, endsAt }: { stats: Stats; startsAt: string; endsAt: string }) {
  const data = fillTimeline(stats.timeline, startsAt, endsAt)
  if (data.length === 0 || stats.checkedIn === 0) {
    return (
      <EmptyState icon={<BarChart3 size={40} />} title="No check-ins yet">
        <p className="text-sm">The chart fills in as gate scans sync and attendees self check-in.</p>
      </EmptyState>
    )
  }
  return (
    <div className="h-72">
      <ResponsiveContainer width="100%" height="100%">
        <ComposedChart data={data} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
          <CartesianGrid stroke="#e2e8f0" strokeDasharray="3 3" vertical={false} />
          <XAxis dataKey="label" tick={{ fontSize: 12, fill: '#64748b' }} tickLine={false} axisLine={false} minTickGap={24} />
          <YAxis yAxisId="bucket" allowDecimals={false} tick={{ fontSize: 12, fill: '#64748b' }} tickLine={false} axisLine={false} />
          <YAxis yAxisId="total" orientation="right" allowDecimals={false} hide />
          <Tooltip
            contentStyle={{ borderRadius: 12, border: '1px solid #e2e8f0', fontSize: 13 }}
            formatter={(value, name) => [value, name === 'checkIns' ? 'In this 15 min' : 'Total checked in']}
          />
          <Bar yAxisId="bucket" dataKey="checkIns" fill="#A5B4FC" radius={[4, 4, 0, 0]} maxBarSize={28} />
          <Line yAxisId="total" dataKey="total" stroke="#4338CA" strokeWidth={2.5} dot={false} type="monotone" />
        </ComposedChart>
      </ResponsiveContainer>
    </div>
  )
}

const METHOD_COLORS = { qr: '#4338CA', geofence: '#10B981' }

export function MethodDonut({ byMethod }: { byMethod: Stats['byMethod'] }) {
  const total = byMethod.qr + byMethod.geofence
  const data = [
    { key: 'qr' as const, name: 'QR at the gate', value: byMethod.qr },
    { key: 'geofence' as const, name: 'Geofenced self check-in', value: byMethod.geofence },
  ]
  return (
    <div className="flex items-center gap-4">
      <div className="relative size-32 shrink-0">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={total ? data : [{ key: 'none', value: 1 }]} dataKey="value" innerRadius={42} outerRadius={60} paddingAngle={total ? 2 : 0} stroke="none">
              {(total ? data : [{ key: 'none' }]).map((d) => (
                <Cell key={d.key} fill={d.key === 'none' ? '#e2e8f0' : METHOD_COLORS[d.key as 'qr' | 'geofence']} />
              ))}
            </Pie>
          </PieChart>
        </ResponsiveContainer>
        <div className="absolute inset-0 grid place-items-center text-center">
          <div>
            <p className="text-xl font-bold text-slate-900">{total}</p>
            <p className="text-[10px] uppercase tracking-wide text-slate-500">check-ins</p>
          </div>
        </div>
      </div>
      <ul className="space-y-2 text-sm">
        {data.map((d) => (
          <li key={d.key} className="flex items-center gap-2">
            <span className="size-2.5 rounded-full" style={{ background: METHOD_COLORS[d.key] }} />
            <span className="text-slate-600">{d.name}</span>
            <span className="font-semibold text-slate-900">{d.value}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

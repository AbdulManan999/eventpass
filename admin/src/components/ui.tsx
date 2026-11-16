import type { ReactNode } from 'react'
import type { Category } from '../api/types'
import { CATEGORY_STYLE, type EventStatus } from '../lib/format'

export function Spinner({ className = '' }: { className?: string }) {
  return (
    <div
      role="status"
      aria-label="Loading"
      className={`size-6 animate-spin rounded-full border-2 border-brand-100 border-t-brand-700 ${className}`}
    />
  )
}

export function StatusBadge({ status }: { status: EventStatus }) {
  if (status === 'live') {
    return (
      <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
        <span className="relative flex size-2">
          <span className="absolute inline-flex size-full animate-ping rounded-full bg-emerald-400 opacity-75" />
          <span className="relative inline-flex size-2 rounded-full bg-emerald-500" />
        </span>
        Live
      </span>
    )
  }
  const style = status === 'upcoming' ? 'bg-brand-50 text-brand-700' : 'bg-slate-100 text-slate-500'
  return (
    <span className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${style}`}>
      {status === 'upcoming' ? 'Upcoming' : 'Ended'}
    </span>
  )
}

export function CategoryBadge({ category }: { category: Category }) {
  const s = CATEGORY_STYLE[category]
  return (
    <span className="rounded-full px-2.5 py-0.5 text-xs font-semibold" style={{ color: s.color, background: s.bg }}>
      {s.label}
    </span>
  )
}

export function ProgressBar({ value, max, color = 'bg-brand-600' }: { value: number; max: number; color?: string }) {
  const pct = max > 0 ? Math.min(100, (value / max) * 100) : 0
  return (
    <div className="h-2 overflow-hidden rounded-full bg-slate-100">
      <div className={`h-full rounded-full transition-all duration-700 ${color}`} style={{ width: `${pct}%` }} />
    </div>
  )
}

export function Card({ title, action, children, className = '' }: { title?: ReactNode; action?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={`card p-5 ${className}`}>
      {(title || action) && (
        <div className="mb-4 flex items-center justify-between gap-3">
          <h2 className="font-semibold text-slate-900">{title}</h2>
          {action}
        </div>
      )}
      {children}
    </section>
  )
}

export function EmptyState({ icon, title, children }: { icon: ReactNode; title: string; children?: ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-2 py-10 text-center text-slate-500">
      <div className="text-slate-300">{icon}</div>
      <p className="font-medium text-slate-700">{title}</p>
      {children}
    </div>
  )
}

export function ErrorNote({ error }: { error: unknown }) {
  if (!error) return null
  return (
    <p role="alert" className="rounded-lg bg-rose-50 px-3 py-2 text-sm text-rose-700">
      {(error as Error).message}
    </p>
  )
}

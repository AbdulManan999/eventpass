import { Monitor, Moon, Sun, type LucideIcon } from 'lucide-react'
import type { MouseEvent } from 'react'
import { THEME_PREFERENCES, type ThemePreference } from '../lib/theme'
import { useTheme } from './ThemeContext'

const OPTIONS: Record<ThemePreference, { icon: LucideIcon; label: string }> = {
  system: { icon: Monitor, label: 'Match system' },
  light: { icon: Sun, label: 'Light' },
  dark: { icon: Moon, label: 'Dark' },
}

/** System / Light / Dark switch with a sliding thumb. */
export function ThemeToggle({ className = '' }: { className?: string }) {
  const { preference, setPreference } = useTheme()
  const index = THEME_PREFERENCES.indexOf(preference)

  const pick = (p: ThemePreference) => (e: MouseEvent<HTMLButtonElement>) => {
    const r = e.currentTarget.getBoundingClientRect()
    setPreference(p, { x: r.left + r.width / 2, y: r.top + r.height / 2 })
  }

  return (
    <div role="radiogroup" aria-label="Theme" className={`relative flex rounded-full bg-slate-100 p-1 ${className}`}>
      <span
        aria-hidden
        className="absolute left-1 top-1 size-7 rounded-full bg-surface shadow-sm ring-1 ring-slate-200 transition-transform duration-300 ease-[cubic-bezier(0.34,1.56,0.64,1)]"
        style={{ transform: `translateX(${index * 100}%)` }}
      />
      {THEME_PREFERENCES.map((p) => {
        const { icon: Icon, label } = OPTIONS[p]
        const active = p === preference
        return (
          <button
            key={p}
            type="button"
            role="radio"
            aria-checked={active}
            aria-label={label}
            title={label}
            onClick={pick(p)}
            className={`relative z-10 grid size-7 place-items-center rounded-full transition-colors duration-300 focus-visible:outline-2 focus-visible:outline-brand-500 ${
              active ? 'text-brand-ink' : 'text-slate-400 hover:text-slate-700'
            }`}
          >
            <Icon size={15} className={`transition-transform duration-500 ${active ? 'rotate-0 scale-110' : p === 'light' ? '-rotate-90 scale-90' : 'scale-90'}`} />
          </button>
        )
      })}
    </div>
  )
}

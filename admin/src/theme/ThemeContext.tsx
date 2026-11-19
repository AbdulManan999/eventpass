import { createContext, use, useCallback, useEffect, useMemo, useState, useSyncExternalStore, type ReactNode } from 'react'
import { flushSync } from 'react-dom'
import { CHART_THEME, parsePreference, resolveTheme, revealRadius, THEME_STORAGE_KEY, type ChartTheme, type ResolvedTheme, type ThemePreference } from '../lib/theme'

interface ThemeState {
  preference: ThemePreference
  resolved: ResolvedTheme
  /** Colours for charts and maps in the current theme. */
  chart: ChartTheme
  /** `origin` is where the user clicked; the new theme spreads out from there. */
  setPreference: (preference: ThemePreference, origin?: { x: number; y: number }) => void
}

const ThemeContext = createContext<ThemeState | null>(null)

const darkQuery = () => window.matchMedia('(prefers-color-scheme: dark)')

function subscribeToSystem(onChange: () => void) {
  const mq = darkQuery()
  mq.addEventListener('change', onChange)
  return () => mq.removeEventListener('change', onChange)
}

function readStored(): ThemePreference {
  try {
    return parsePreference(localStorage.getItem(THEME_STORAGE_KEY))
  } catch {
    return 'system' // storage blocked (private mode, strict cookie settings)
  }
}

function applyToDocument(theme: ResolvedTheme) {
  const root = document.documentElement
  root.dataset.theme = theme
  root.style.colorScheme = theme // native controls, date pickers and scrollbars
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [preference, setPreferenceState] = useState(readStored)
  const systemDark = useSyncExternalStore(subscribeToSystem, () => darkQuery().matches)
  const resolved = resolveTheme(preference, systemDark)

  useEffect(() => applyToDocument(resolved), [resolved])

  const setPreference = useCallback((next: ThemePreference, origin?: { x: number; y: number }) => {
    try {
      localStorage.setItem(THEME_STORAGE_KEY, next)
    } catch {
      // Not saved, but still applied for this visit.
    }
    const nextResolved = resolveTheme(next, darkQuery().matches)
    const update = () => {
      setPreferenceState(next)
      applyToDocument(nextResolved)
    }

    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    const changesColours = nextResolved !== document.documentElement.dataset.theme
    if (!document.startViewTransition || reduceMotion || !changesColours) {
      update()
      return
    }

    // Snapshot the old theme, render the new one, then reveal it in a growing circle.
    const { x, y } = origin ?? { x: window.innerWidth - 40, y: 32 }
    const transition = document.startViewTransition(() => flushSync(update))
    transition.ready
      .then(() => {
        const r = revealRadius(x, y, window.innerWidth, window.innerHeight)
        document.documentElement.animate(
          { clipPath: [`circle(0px at ${x}px ${y}px)`, `circle(${r}px at ${x}px ${y}px)`] },
          { duration: 550, easing: 'cubic-bezier(0.4, 0, 0.2, 1)', pseudoElement: '::view-transition-new(root)' },
        )
      })
      .catch(() => {}) // skipped transitions still apply the theme
  }, [])

  const value = useMemo(
    () => ({ preference, resolved, chart: CHART_THEME[resolved], setPreference }),
    [preference, resolved, setPreference],
  )
  return <ThemeContext value={value}>{children}</ThemeContext>
}

// eslint-disable-next-line react-refresh/only-export-components
export function useTheme(): ThemeState {
  const ctx = use(ThemeContext)
  if (!ctx) throw new Error('useTheme must be used inside ThemeProvider')
  return ctx
}

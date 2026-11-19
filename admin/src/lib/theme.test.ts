import indexHtml from '../../index.html?raw'
import { describe, expect, it } from 'vitest'
import { CHART_THEME, parsePreference, resolveTheme, revealRadius, THEME_STORAGE_KEY } from './theme'

describe('theme', () => {
  it('falls back to the system setting for missing or unknown values', () => {
    expect(parsePreference(null)).toBe('system')
    expect(parsePreference('sepia')).toBe('system')
    expect(parsePreference('dark')).toBe('dark')
    expect(parsePreference('light')).toBe('light')
  })

  it('System follows the OS; Light and Dark override it', () => {
    expect(resolveTheme('system', true)).toBe('dark')
    expect(resolveTheme('system', false)).toBe('light')
    expect(resolveTheme('light', true)).toBe('light')
    expect(resolveTheme('dark', false)).toBe('dark')
  })

  it('the reveal circle reaches the farthest corner of the window', () => {
    expect(revealRadius(0, 0, 300, 400)).toBe(500)
    expect(revealRadius(300, 400, 300, 400)).toBe(500)
    expect(revealRadius(150, 200, 300, 400)).toBe(250)
  })

  it('both themes define the same chart colours', () => {
    expect(Object.keys(CHART_THEME.dark).sort()).toEqual(Object.keys(CHART_THEME.light).sort())
    expect(Object.keys(CHART_THEME.dark.methods).sort()).toEqual(['geofence', 'nfc', 'qr'])
  })

  it('the no-flash script in index.html uses the same storage key', () => {
    expect(indexHtml).toContain(`localStorage.getItem('${THEME_STORAGE_KEY}')`)
  })
})

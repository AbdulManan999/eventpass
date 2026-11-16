import { useQueryClient } from '@tanstack/react-query'
import { createContext, use, useCallback, useEffect, useMemo, useState, type ReactNode } from 'react'
import { api, ApiError, setUnauthorizedHandler, tokenStore } from '../api/client'
import type { User } from '../api/types'

interface AuthState {
  user: User | null
  /** True until the stored token has been checked against the API. */
  restoring: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthState | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient()
  const [user, setUser] = useState<User | null>(null)
  const [restoring, setRestoring] = useState(() => tokenStore.get() !== null)

  const logout = useCallback(() => {
    tokenStore.set(null)
    setUser(null)
    queryClient.clear()
  }, [queryClient])

  useEffect(() => {
    setUnauthorizedHandler(logout)
    if (!tokenStore.get()) return
    api<User>('/me')
      .then((me) => (me.role === 'organizer' ? setUser(me) : logout()))
      .catch(logout)
      .finally(() => setRestoring(false))
  }, [logout])

  const login = useCallback(async (email: string, password: string) => {
    const res = await api<{ token: string; user: User }>('/auth/login', { method: 'POST', body: { email, password } })
    if (res.user.role !== 'organizer') {
      throw new ApiError(403, 'not_organizer', 'The dashboard is for event organizers. Attendees use the mobile app.')
    }
    tokenStore.set(res.token)
    setUser(res.user)
  }, [])

  const value = useMemo(() => ({ user, restoring, login, logout }), [user, restoring, login, logout])
  return <AuthContext value={value}>{children}</AuthContext>
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth(): AuthState {
  const ctx = use(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider')
  return ctx
}

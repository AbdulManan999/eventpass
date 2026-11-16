import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { api } from './client'
import type { AttendeeTicket, EventSummary, NewEvent, Scan, StaffMember, Stats } from './types'

/** How often live dashboard data is refreshed. */
export const LIVE_INTERVAL_MS = 5_000

export const useMyEvents = () =>
  useQuery({
    queryKey: ['organizer-events'],
    queryFn: () => api<EventSummary[]>('/organizer/events'),
    refetchInterval: 15_000,
  })

export const useEvent = (id: string) =>
  useQuery({ queryKey: ['event', id], queryFn: () => api<EventSummary>(`/events/${id}`) })

export const useStats = (id: string) =>
  useQuery({
    queryKey: ['stats', id],
    queryFn: () => api<Stats>(`/events/${id}/stats`),
    refetchInterval: LIVE_INTERVAL_MS,
  })

export const useScans = (id: string) =>
  useQuery({
    queryKey: ['scans', id],
    queryFn: () => api<Scan[]>(`/events/${id}/scans?limit=50`),
    refetchInterval: LIVE_INTERVAL_MS,
  })

export const useAttendees = (id: string, q: string) =>
  useQuery({
    queryKey: ['attendees', id, q],
    queryFn: () => api<AttendeeTicket[]>(`/events/${id}/tickets?q=${encodeURIComponent(q)}`),
    refetchInterval: 15_000,
    placeholderData: keepPreviousData,
  })

export const useStaff = (id: string) =>
  useQuery({ queryKey: ['staff', id], queryFn: () => api<StaffMember[]>(`/events/${id}/staff`) })

export function useCreateEvent() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (body: NewEvent) => api<EventSummary>('/events', { method: 'POST', body }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['organizer-events'] }),
  })
}

export function useRevokeTicket(eventId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (ticketId: string) => api(`/events/${eventId}/tickets/${ticketId}/revoke`, { method: 'POST', body: {} }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['attendees', eventId] })
      qc.invalidateQueries({ queryKey: ['stats', eventId] })
    },
  })
}

export function useAddStaff(eventId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (email: string) => api(`/events/${eventId}/staff`, { method: 'POST', body: { email } }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['staff', eventId] }),
  })
}

export function useRemoveStaff(eventId: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (userId: string) => api(`/events/${eventId}/staff/${userId}`, { method: 'DELETE' }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['staff', eventId] }),
  })
}

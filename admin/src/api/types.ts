export type Category = 'tech' | 'music' | 'sports' | 'business' | 'community'

export interface User {
  id: string
  email: string
  name: string
  role: 'attendee' | 'organizer'
}

export interface Venue {
  name: string
  latitude: number
  longitude: number
  geofenceRadiusM: number
}

export interface EventSummary {
  id: string
  title: string
  description: string
  category: Category
  venue: Venue
  startsAt: string
  endsAt: string
  capacity: number
  ticketsIssued: number
  checkedIn: number
}

export interface Stats {
  capacity: number
  issued: number
  revoked: number
  checkedIn: number
  rejectedScans: number
  byMethod: { qr: number; geofence: number }
  timeline: { at: string; checkIns: number }[]
  gates: { deviceId: string; scans: number; accepted: number }[]
}

export type ScanResult = 'accepted' | 'duplicate' | 'revoked' | 'invalid'
export type CheckInMethod = 'qr' | 'geofence'

export interface Scan {
  id: string
  result: ScanResult
  method: CheckInMethod
  deviceId: string
  scannedAt: string
  syncedAt: string
  distanceM: number | null
  location: { latitude: number; longitude: number } | null
  scannedBy: string
  holderName: string | null
}

export interface AttendeeTicket {
  id: string
  status: 'valid' | 'revoked'
  issuedAt: string
  holder: { name: string; email: string }
  checkedInAt: string | null
  checkInMethod: CheckInMethod | null
}

export interface StaffMember {
  userId: string
  name: string
  email: string
  scans: number
}

export interface NewEvent {
  title: string
  description: string
  category: Category
  venueName: string
  latitude: number
  longitude: number
  geofenceRadiusM: number
  startsAt: string
  endsAt: string
  capacity: number
}

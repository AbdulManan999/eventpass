import { LocateFixed } from 'lucide-react'
import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router'
import { useCreateEvent } from '../api/hooks'
import type { Category } from '../api/types'
import { Card, ErrorNote } from '../components/ui'
import { VenueMap } from '../components/VenueMap'
import { CATEGORY_STYLE, formatDistance } from '../lib/format'

/** `<input type="datetime-local">` value for a date, in the browser's time zone. */
const toLocalInput = (d: Date) => {
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

const inHours = (h: number) => {
  const d = new Date(Date.now() + h * 3_600_000)
  d.setMinutes(0, 0, 0)
  return d
}

export function NewEventPage() {
  const navigate = useNavigate()
  const create = useCreateEvent()
  const [form, setForm] = useState({
    title: '',
    description: '',
    category: 'tech' as Category,
    venueName: '',
    latitude: 31.4757,
    longitude: 74.3424,
    geofenceRadiusM: 200,
    startsAt: toLocalInput(inHours(24)),
    endsAt: toLocalInput(inHours(27)),
    capacity: 100,
  })
  const [locating, setLocating] = useState(false)
  const set = <K extends keyof typeof form>(key: K, value: (typeof form)[K]) => setForm((f) => ({ ...f, [key]: value }))

  const useMyLocation = () => {
    if (!navigator.geolocation) return
    setLocating(true)
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setForm((f) => ({ ...f, latitude: Number(pos.coords.latitude.toFixed(6)), longitude: Number(pos.coords.longitude.toFixed(6)) }))
        setLocating(false)
      },
      () => setLocating(false),
      { enableHighAccuracy: true, timeout: 10_000 },
    )
  }

  const submit = (e: FormEvent) => {
    e.preventDefault()
    create.mutate(
      {
        ...form,
        startsAt: new Date(form.startsAt).toISOString(),
        endsAt: new Date(form.endsAt).toISOString(),
      },
      { onSuccess: (event) => navigate(`/events/${event.id}`) },
    )
  }

  return (
    <form onSubmit={submit} className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">New event</h1>
        <p className="mt-1 text-sm text-slate-500">A signing key pair is generated for the event when you create it.</p>
      </div>

      <div className="grid gap-6 lg:grid-cols-5">
        <Card title="Details" className="space-y-4 lg:col-span-2">
          <div>
            <label className="label" htmlFor="title">Title</label>
            <input id="title" className="input" required maxLength={200} value={form.title} onChange={(e) => set('title', e.target.value)} placeholder="Lahore Flutter Meetup" />
          </div>
          <div>
            <label className="label" htmlFor="description">Description</label>
            <textarea id="description" className="input min-h-24" maxLength={2000} value={form.description} onChange={(e) => set('description', e.target.value)} />
          </div>
          <div>
            <span className="label">Category</span>
            <div className="flex flex-wrap gap-2">
              {(Object.keys(CATEGORY_STYLE) as Category[]).map((c) => (
                <button
                  key={c}
                  type="button"
                  onClick={() => set('category', c)}
                  className="rounded-full border px-3 py-1 text-sm font-medium transition"
                  style={
                    form.category === c
                      ? { background: CATEGORY_STYLE[c].color, borderColor: CATEGORY_STYLE[c].color, color: '#fff' }
                      : { borderColor: '#cbd5e1', color: '#475569' }
                  }
                >
                  {CATEGORY_STYLE[c].label}
                </button>
              ))}
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="label" htmlFor="startsAt">Starts</label>
              <input id="startsAt" className="input" type="datetime-local" required value={form.startsAt} onChange={(e) => set('startsAt', e.target.value)} />
            </div>
            <div>
              <label className="label" htmlFor="endsAt">Ends</label>
              <input id="endsAt" className="input" type="datetime-local" required value={form.endsAt} onChange={(e) => set('endsAt', e.target.value)} />
            </div>
          </div>
          <div>
            <label className="label" htmlFor="capacity">Capacity</label>
            <input id="capacity" className="input" type="number" min={1} required value={form.capacity} onChange={(e) => set('capacity', Number(e.target.value))} />
          </div>
        </Card>

        <Card
          title="Venue and geofence"
          className="space-y-4 lg:col-span-3"
          action={
            <button type="button" className="btn-ghost px-2 py-1" onClick={useMyLocation} disabled={locating}>
              <LocateFixed size={16} /> {locating ? 'Locating…' : 'Use my location'}
            </button>
          }
        >
          <div>
            <label className="label" htmlFor="venueName">Venue name</label>
            <input id="venueName" className="input" required maxLength={200} value={form.venueName} onChange={(e) => set('venueName', e.target.value)} placeholder="Arfa Software Technology Park, Lahore" />
          </div>
          <VenueMap
            latitude={form.latitude}
            longitude={form.longitude}
            radiusM={form.geofenceRadiusM}
            onPick={(latitude, longitude) => setForm((f) => ({ ...f, latitude, longitude }))}
            className="h-80"
          />
          <p className="text-xs text-slate-500">
            Click the map to place the venue · {form.latitude}, {form.longitude}
          </p>
          <div>
            <div className="mb-1 flex justify-between">
              <label className="label" htmlFor="radius">Self check-in radius</label>
              <span className="text-sm font-semibold text-brand-700">{formatDistance(form.geofenceRadiusM)}</span>
            </div>
            <input
              id="radius"
              type="range"
              min={50}
              max={1000}
              step={25}
              value={form.geofenceRadiusM}
              onChange={(e) => set('geofenceRadiusM', Number(e.target.value))}
              className="w-full accent-brand-700"
            />
            <p className="mt-1 text-xs text-slate-500">
              Attendees inside this circle can check themselves in from their phone, from 2 hours before the start.
            </p>
          </div>
        </Card>
      </div>

      <ErrorNote error={create.error} />
      <div className="flex justify-end gap-2">
        <button type="button" className="btn-ghost" onClick={() => navigate(-1)}>Cancel</button>
        <button type="submit" className="btn-primary" disabled={create.isPending}>
          {create.isPending ? 'Creating…' : 'Create event'}
        </button>
      </div>
    </form>
  )
}

import { MapPin, QrCode, Ticket, WifiOff } from 'lucide-react'
import { useState, type FormEvent } from 'react'
import { useAuth } from '../auth/AuthContext'
import { ErrorNote } from '../components/ui'
import { ThemeToggle } from '../theme/ThemeToggle'

export function LoginPage() {
  const { login } = useAuth()
  const [email, setEmail] = useState('organizer@eventpass.dev')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<unknown>(null)
  const [busy, setBusy] = useState(false)

  const submit = async (e: FormEvent) => {
    e.preventDefault()
    setBusy(true)
    setError(null)
    try {
      await login(email, password)
    } catch (err) {
      setError(err)
    } finally {
      setBusy(false)
    }
  }

  const features = [
    { icon: QrCode, text: 'Signed QR tickets verified offline at the gate' },
    { icon: MapPin, text: 'Geofenced self check-in from the attendee’s phone' },
    { icon: WifiOff, text: 'Scans queue on the device and sync when back online' },
  ]

  return (
    <div className="grid min-h-screen lg:grid-cols-2">
      <div className="hidden flex-col justify-between bg-gradient-to-br from-brand-900 via-brand-700 to-brand-500 p-12 text-white lg:flex">
        <div className="flex items-center gap-2 text-lg font-semibold">
          <span className="grid size-9 place-items-center rounded-lg bg-white/15">
            <Ticket size={20} />
          </span>
          EventPass
        </div>
        <div>
          <h1 className="text-4xl font-bold leading-tight">Run the door.<br />Even when the Wi-Fi doesn’t.</h1>
          <ul className="mt-8 space-y-4">
            {features.map(({ icon: Icon, text }) => (
              <li key={text} className="flex items-center gap-3 text-brand-100">
                <Icon size={20} className="shrink-0" /> {text}
              </li>
            ))}
          </ul>
        </div>
        <p className="text-sm text-brand-100/80">Organizer dashboard</p>
      </div>

      <div className="relative flex items-center justify-center p-6">
        <div className="absolute right-4 top-4">
          <ThemeToggle />
        </div>
        <form onSubmit={submit} className="w-full max-w-sm space-y-5">
          <div>
            <h2 className="text-2xl font-bold text-slate-900">Sign in</h2>
            <p className="mt-1 text-sm text-slate-500">Manage your events and watch check-ins live.</p>
          </div>
          <div>
            <label className="label" htmlFor="email">Email</label>
            <input id="email" className="input" type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
          </div>
          <div>
            <label className="label" htmlFor="password">Password</label>
            <input id="password" className="input" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
          </div>
          <ErrorNote error={error} />
          <button type="submit" className="btn-primary w-full" disabled={busy}>
            {busy ? 'Signing in…' : 'Sign in'}
          </button>
          <p className="rounded-lg bg-slate-100 px-3 py-2 text-xs text-slate-600">
            Demo: <code>organizer@eventpass.dev</code> / <code>eventpass-demo</code> (run <code>npm run seed</code> in the backend first)
          </p>
        </form>
      </div>
    </div>
  )
}

import { lazy, Suspense } from 'react'
import { Navigate, Route, Routes } from 'react-router'
import { useAuth } from './auth/AuthContext'
import { Layout } from './components/Layout'
import { Spinner } from './components/ui'
import { EventsPage } from './pages/EventsPage'
import { LoginPage } from './pages/LoginPage'

// Charts and maps are only needed on these pages, so they load on demand.
const EventDashboardPage = lazy(() => import('./pages/EventDashboardPage').then((m) => ({ default: m.EventDashboardPage })))
const NewEventPage = lazy(() => import('./pages/NewEventPage').then((m) => ({ default: m.NewEventPage })))

export function App() {
  const { user, restoring } = useAuth()

  if (restoring) {
    return (
      <div className="grid h-screen place-items-center">
        <Spinner />
      </div>
    )
  }

  if (!user) {
    return (
      <Routes>
        <Route path="*" element={<LoginPage />} />
      </Routes>
    )
  }

  return (
    <Layout>
      <Suspense fallback={<Spinner className="mx-auto mt-10" />}>
        <Routes>
          <Route path="/" element={<EventsPage />} />
          <Route path="/events/new" element={<NewEventPage />} />
          <Route path="/events/:id" element={<EventDashboardPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Suspense>
    </Layout>
  )
}

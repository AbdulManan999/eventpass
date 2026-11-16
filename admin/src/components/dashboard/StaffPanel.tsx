import { UserPlus, Users, X } from 'lucide-react'
import { useState, type FormEvent } from 'react'
import { useAddStaff, useRemoveStaff, useStaff } from '../../api/hooks'
import { EmptyState, ErrorNote, Spinner } from '../ui'

export function StaffPanel({ eventId }: { eventId: string }) {
  const staff = useStaff(eventId)
  const add = useAddStaff(eventId)
  const remove = useRemoveStaff(eventId)
  const [email, setEmail] = useState('')

  const submit = (e: FormEvent) => {
    e.preventDefault()
    add.mutate(email.trim(), { onSuccess: () => setEmail('') })
  }

  return (
    <div className="space-y-4">
      <form onSubmit={submit} className="flex gap-2">
        <input className="input" type="email" required placeholder="staff@example.com" value={email} onChange={(e) => setEmail(e.target.value)} />
        <button type="submit" className="btn-primary px-3" disabled={add.isPending} title="Add staff">
          <UserPlus size={16} />
        </button>
      </form>
      <p className="text-xs text-slate-500">Staff sign in to the mobile app with this email to scan tickets for this event.</p>
      <ErrorNote error={add.error ?? remove.error} />

      {staff.isPending && <Spinner />}
      {staff.data?.length === 0 && <EmptyState icon={<Users size={36} />} title="No staff yet" />}
      <ul className="divide-y divide-slate-100">
        {staff.data?.map((m) => (
          <li key={m.userId} className="flex items-center gap-3 py-2.5">
            <span className="grid size-9 shrink-0 place-items-center rounded-full bg-brand-50 text-sm font-semibold text-brand-700">
              {m.name
                .split(' ')
                .map((p) => p[0])
                .slice(0, 2)
                .join('')}
            </span>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-medium text-slate-900">{m.name}</p>
              <p className="truncate text-xs text-slate-500">
                {m.email} · {m.scans} scans
              </p>
            </div>
            <button
              type="button"
              className="rounded-md p-1 text-slate-400 hover:bg-rose-50 hover:text-rose-600"
              title="Remove"
              disabled={remove.isPending}
              onClick={() => remove.mutate(m.userId)}
            >
              <X size={16} />
            </button>
          </li>
        ))}
      </ul>
    </div>
  )
}

import { describe, expect, it } from 'vitest'
import { BUCKET_MS, eventStatus, fillTimeline, formatDistance, percent, timeAgo } from './format'

const start = '2026-11-16T10:00:00.000Z'
const end = '2026-11-16T14:00:00.000Z'
const at = (min: number) => new Date(Date.parse(start) + min * 60_000).toISOString()

describe('eventStatus', () => {
  it('is upcoming, live, then ended', () => {
    expect(eventStatus(start, end, Date.parse(start) - 1)).toBe('upcoming')
    expect(eventStatus(start, end, Date.parse(start) + 1)).toBe('live')
    expect(eventStatus(start, end, Date.parse(end) + 1)).toBe('ended')
  })
})

describe('fillTimeline', () => {
  it('fills gaps with zeros and keeps a running total', () => {
    const points = fillTimeline(
      [
        { at: at(0), checkIns: 4 },
        { at: at(45), checkIns: 2 },
      ],
      start,
      end,
      Date.parse(at(50)),
    )
    expect(points.map((p) => p.checkIns)).toEqual([4, 0, 0, 2])
    expect(points.map((p) => p.total)).toEqual([4, 4, 4, 6])
    expect(points[1]!.at - points[0]!.at).toBe(BUCKET_MS)
  })

  it('includes early check-ins before the start', () => {
    const points = fillTimeline([{ at: at(-30), checkIns: 3 }], start, end, Date.parse(at(10)))
    expect(points.map((p) => p.checkIns)).toEqual([3, 0, 0])
  })

  it('stops at the event end once the event is over', () => {
    const points = fillTimeline([], start, end, Date.parse(end) + 86_400_000)
    expect(points).toHaveLength(17) // 10:00 to 14:00 inclusive, every 15 minutes
  })

  it('is empty for an event that has not started', () => {
    expect(fillTimeline([], start, end, Date.parse(start) - 3_600_000)).toEqual([])
  })
})

describe('small formatters', () => {
  it('formats distances, percentages and relative times', () => {
    expect(formatDistance(180.4)).toBe('180 m')
    expect(formatDistance(1530)).toBe('1.5 km')
    expect(percent(1, 3)).toBe(33)
    expect(percent(5, 0)).toBe(0)
    expect(timeAgo(at(0), Date.parse(at(0)) + 90_000)).toBe('1m ago')
  })
})

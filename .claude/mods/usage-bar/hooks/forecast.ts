import type { Limit } from '../types'

export const FIVE_HOURS = 5 * 60 * 60 * 1000
export const WEEK = 7 * 24 * 60 * 60 * 1000

export type Forecast =
  | { kind: 'unknown' }
  | { kind: 'ok'; atReset: number }
  | { kind: 'exceeds'; hitsAt: number }

// Linear pace over the elapsed part of the window: the rate so far, carried to reset.
export const forecast = (limit: Limit, windowMs: number, now: number): Forecast => {
  if (!limit.resetsAt) {
    return { kind: 'unknown' }
  }

  const resetsAt = Date.parse(limit.resetsAt)
  const elapsed = windowMs - (resetsAt - now)

  // Too early in the window for the pace to mean anything.
  if (elapsed < windowMs * 0.02 || limit.percentUsed <= 0) {
    return { kind: 'unknown' }
  }

  const perMs = limit.percentUsed / elapsed
  const atReset = limit.percentUsed + perMs * (resetsAt - now)

  if (limit.percentUsed >= 100 || atReset > 100) {
    return { kind: 'exceeds', hitsAt: now + Math.max(0, (100 - limit.percentUsed) / perMs) }
  }

  return { kind: 'ok', atReset }
}

export const duration = (ms: number): string => {
  const minutes = Math.max(0, Math.round(ms / 60000))
  const days = Math.floor(minutes / 1440)
  const hours = Math.floor((minutes % 1440) / 60)
  const mins = minutes % 60

  if (days > 0) {
    return `${days}d ${hours}h`
  }

  if (hours > 0) {
    return `${hours}h ${mins}m`
  }

  return `${mins}m`
}

export const bar = (percent: number, width: number): string => {
  const filled = Math.round((Math.min(100, Math.max(0, percent)) / 100) * width)

  return '█'.repeat(filled) + '░'.repeat(width - filled)
}

export const colorFor = (percent: number): string =>
  percent >= 90 ? 'red' : percent >= 70 ? 'yellow' : 'green'

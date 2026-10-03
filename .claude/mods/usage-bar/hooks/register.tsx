import { atom, read, update } from 'claude-code'
import type { Register, SessionRateLimit } from 'claude-code'

import type { Limit, Limits } from '../types'
import { FIVE_HOURS, WEEK, bar, colorFor, duration, forecast } from './forecast'

const limits = atom({ plugin: 'usage-bar', key: 'limits' } as const, {
  fiveHour: null,
  weekly: null,
})
const isVisible = atom({ plugin: 'usage-bar', key: 'isVisible' } as const, true)
const now = atom({ plugin: 'usage-bar', key: 'now' } as const, 0)

const pick = (rateLimits: SessionRateLimit[], kind: string): Limit | null => {
  const found = rateLimits.find(one => one.kind === kind)

  return found ? { percentUsed: found.percentUsed, resetsAt: found.resetsAt } : null
}

const toLimits = (rateLimits: SessionRateLimit[]): Limits => ({
  fiveHour: pick(rateLimits, 'five_hour'),
  weekly: pick(rateLimits, 'seven_day'),
})

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'usage-bar',
      description: 'Toggle the usage limit bars above the prompt',
      immediate: true,
    })

    const usage = await $.session.usage()
    const t = await $.clock.now()
    await update($, limits, () => toLimits(usage.rateLimits))
    await update($, now, () => t)

    // Keeps the "resets in" countdowns fresh between turns.
    $.clock.every(60_000, () => {
      void $.clock.now().then(t => update($, now, () => t))
    })

    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('rateLimits')) {
      const t = await $.clock.now()
      await update($, limits, () => toLimits(e.rateLimits))
      await update($, now, () => t)
    }

    return next(e)
  })

  on('command.run', { command: 'usage-bar' }, async $ => {
    const shown = await update($, isVisible, v => !v)

    return { text: shown ? 'Usage bars shown.' : 'Usage bars hidden.' }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const { fiveHour, weekly } = await read($, limits)

    if (e.props.hasSurvey || !(await read($, isVisible)) || (!fiveHour && !weekly)) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const t = (await read($, now)) || (await $.clock.now())
    const width = Math.max(10, Math.min(30, e.props.bodyColumns - 50))

    const row = (label: string, limit: Limit | null, windowMs: number, withForecast: boolean) => {
      if (!limit) {
        return (
          <Text key={label} dimColor>
            {label} no reading yet
          </Text>
        )
      }

      const resets = limit.resetsAt
        ? `resets in ${duration(Date.parse(limit.resetsAt) - t)}`
        : ''
      const pace = withForecast ? forecast(limit, windowMs, t) : { kind: 'unknown' as const }

      return (
        <Box key={label} flexDirection="row">
          <Text>{label} </Text>
          <Text color={colorFor(limit.percentUsed)}>{bar(limit.percentUsed, width)}</Text>
          <Text> {limit.percentUsed.toFixed(0).padStart(3)}% </Text>
          <Text dimColor>{resets}</Text>
          {pace.kind === 'ok' && <Text dimColor> · on pace for ~{pace.atReset.toFixed(0)}%</Text>}
          {pace.kind === 'exceeds' && (
            <Text color="red" bold>
              {' '}
              ⚠ on pace to hit limit in {duration(pace.hitsAt - t)}
            </Text>
          )}
        </Box>
      )
    }

    return (
      <Box flexDirection="column">
        {row('5h  ', fiveHour, FIVE_HOURS, false)}
        {row('week', weekly, WEEK, true)}
      </Box>
    )
  })
}

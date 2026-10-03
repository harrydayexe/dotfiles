import { describe, expect, mock, test } from 'claude-code/testing'

import { WEEK, forecast } from './forecast'

const DAY = 24 * 60 * 60 * 1000
const NOW = Date.parse('2026-10-03T12:00:00Z')
const resetIn = (ms: number) => new Date(NOW + ms).toISOString()

describe('forecast', () => {
  test('under pace stays ok', async () => {
    // Half the week gone, 30% used: ~60% at reset.
    const f = forecast({ percentUsed: 30, resetsAt: resetIn(3.5 * DAY) }, WEEK, NOW)
    expect(f.kind).toBe('ok')
  })

  test('over pace predicts the limit before reset', async () => {
    // Two days in, 40% used: hits 100% after 5 days, 2 days before reset.
    const f = forecast({ percentUsed: 40, resetsAt: resetIn(5 * DAY) }, WEEK, NOW)
    expect(f.kind).toBe('exceeds')
    if (f.kind === 'exceeds') {
      expect(Math.round((f.hitsAt - NOW) / DAY)).toBe(3)
    }
  })

  test('too early in the window gives no forecast', async () => {
    const f = forecast({ percentUsed: 5, resetsAt: resetIn(WEEK - 60_000) }, WEEK, NOW)
    expect(f.kind).toBe('unknown')
  })
})

const PROPS = {
  hasSurvey: false,
  isWorking: false,
  maxRows: 10,
  bodyColumns: 120,
}

const measure = {
  context: { window: 200000 },
  rateLimits: [
    { kind: 'five_hour', percentUsed: 42, resetsAt: resetIn(2 * 60 * 60 * 1000) },
    { kind: 'seven_day', percentUsed: 40, resetsAt: resetIn(5 * DAY) },
  ],
  changed: ['rateLimits'],
}

for (const surface of ['terminal', 'desktop'] as const) {
  test(`draws both bars and toggles on ${surface}`, async ($, on) => {
    on('session.usage', () => ({ value: { startedAt: NOW, context: measure.context, rateLimits: [] } }) as never)
    mock.clock(on, { now: NOW })
    on('command.register', () => ({ value: undefined }) as never)
    on('ui.render', ($e, e) => { const { Text } = $e.ui.resolve(e); return <Text>engine</Text> })
    on('session.start', (_$, e) => ({ cwd: e.cwd }))
    on('session.measure', (_$, e) => ({ changed: e.changed }))
    await $.session.start({ cwd: '/', surface, isInteractive: true })
    await $.session.measure(measure as never)

    const shown = await $.ui.mount({ plugin: 'usage-bar', surface, component: 'AbovePrompt', props: PROPS as never })
    expect(await shown.find({ text: '42%' })).toBeTruthy()
    expect(await shown.find({ text: /on pace to hit limit in 3d/ })).toBeTruthy()
    await shown.unmount()

    await $.command.run({ command: 'usage-bar', args: '' } as never)
    const hidden = await $.ui.mount({ plugin: 'usage-bar', surface, component: 'AbovePrompt', props: PROPS as never })
    expect(await hidden.findAll({ text: '42%' })).toHaveLength(0)
  })
}

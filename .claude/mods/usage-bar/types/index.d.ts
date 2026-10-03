export type Limit = { percentUsed: number; resetsAt?: string }

export type Limits = { fiveHour: Limit | null; weekly: Limit | null }

declare module 'claude-code' {
  interface PluginState {
    'usage-bar': { limits: Limits; isVisible: boolean; now: number }
  }
}

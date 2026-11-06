// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

import type { RobotStatus } from './robot-status.js';

const LOW_BATTERY_PERCENT = 20;
const STALE_AFTER_MS = 5_000;

export interface StatusSummary {
  readonly online: number;
  readonly lowBattery: readonly string[];
  readonly stale: readonly string[];
}

/**
 * Groups the latest status of each robot for the dashboard header.
 *
 * @param statuses - Latest status per robot.
 * @param now - Current time, used to find robots that stopped reporting.
 */
export function summarize(statuses: readonly RobotStatus[], now: Date): StatusSummary {
  const lowBattery: string[] = [];
  const stale: string[] = [];

  for (const status of statuses) {
    if (status.batteryPercent < LOW_BATTERY_PERCENT) {
      lowBattery.push(status.robotId);
    }
    if (now.getTime() - status.receivedAt.getTime() > STALE_AFTER_MS) {
      stale.push(status.robotId);
    }
  }

  return { online: statuses.length - stale.length, lowBattery, stale };
}

/** Formats a speed for display, for example "0.45 m/s". */
export function formatSpeed(metersPerSecond: number): string {
  return `${metersPerSecond.toFixed(2)} m/s`;
}

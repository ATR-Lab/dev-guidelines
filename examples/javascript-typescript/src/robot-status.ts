// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

/** Battery and motion state that a robot publishes to the dashboard. */
export interface RobotStatus {
  readonly robotId: string;
  readonly batteryPercent: number;
  readonly linearSpeed: number; // m/s
  readonly mode: RobotMode;
  readonly receivedAt: Date;
}

export type RobotMode = 'idle' | 'teleoperated' | 'autonomous' | 'fault';

const ROBOT_MODES: readonly RobotMode[] = ['idle', 'teleoperated', 'autonomous', 'fault'];

/** Thrown when a message from the robot does not have the fields we expect. */
export class StatusParseError extends Error {
  override readonly name = 'StatusParseError';
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

function isRobotMode(value: unknown): value is RobotMode {
  return typeof value === 'string' && (ROBOT_MODES as readonly string[]).includes(value);
}

/**
 * Parses one JSON status message, for example from a rosbridge WebSocket.
 *
 * @param raw - The message text.
 * @param now - Clock to stamp the message with; pass a fixed date in tests.
 * @returns The validated status.
 * @throws {StatusParseError} If a field is missing or has the wrong type.
 */
export function parseStatus(raw: string, now: () => Date = () => new Date()): RobotStatus {
  const data: unknown = JSON.parse(raw);
  if (!isRecord(data)) {
    throw new StatusParseError('Status message must be a JSON object.');
  }

  const { robot_id: robotId, battery, speed, mode } = data;
  if (typeof robotId !== 'string' || robotId.length === 0) {
    throw new StatusParseError('robot_id must be a non-empty string.');
  }
  if (typeof battery !== 'number' || battery < 0 || battery > 100) {
    throw new StatusParseError('battery must be a number from 0 to 100.');
  }
  if (typeof speed !== 'number' || !Number.isFinite(speed)) {
    throw new StatusParseError('speed must be a finite number.');
  }
  if (!isRobotMode(mode)) {
    throw new StatusParseError(`mode must be one of: ${ROBOT_MODES.join(', ')}.`);
  }

  return { robotId, batteryPercent: battery, linearSpeed: speed, mode, receivedAt: now() };
}

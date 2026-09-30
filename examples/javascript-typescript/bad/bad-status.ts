// Deliberately bad TypeScript: scripts/check-configs.sh expects ESLint, Prettier and tsc to
// reject this file. Do not copy it. Each comment names the rule that should fire.
import { parseStatus } from "../src/robot-status.js"; // prettier (double quotes), no-unused-vars

export function batteryLabel(status: any) { // no-explicit-any
  if (status.battery == null) { // eqeqeq
    return 'unknown'
  }
  return status.battery + '%'; // restrict-plus-operands (any + string)
}

export async function fetchStatus(url: string): Promise<unknown> {
  return fetch(url).then((r) => r.json());
}

export function refresh(url: string): void {
  fetchStatus(url); // no-floating-promises
  const count: number = 'three'; // tsc: string is not assignable to number
  console.log(count); // no-console
}

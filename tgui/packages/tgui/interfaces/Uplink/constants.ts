import { ObjectValues } from 'common/types';

export const OBJECTIVE_STATES = {
  Inactive: 1,
  Active: 2,
  Completed: 3,
  Failed: 4,
  Invalid: 5,
} as const;

export type ObjectiveState = ObjectValues<typeof OBJECTIVE_STATES>;

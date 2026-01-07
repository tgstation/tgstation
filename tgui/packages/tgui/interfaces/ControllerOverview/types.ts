import type { BooleanLike } from 'tgui-core/react';

export type SubsystemData = {
  can_fire: BooleanLike;
  cost_ms: number;
  doesnt_fire: BooleanLike;
  init_order: number;
  initialization_failure_message: string | undefined;
  initialized: BooleanLike;
  last_fire: number;
  name: string;
  next_fire: number;
  ref: string;
  overtime: number;
  tick_usage: number;
  usage_per_tick: number;
};

export type ControllerData = {
  world_time: number;
  fast_update: BooleanLike;
  rolling_length: number;
  map_cpu: number;
  subsystems: SubsystemData[];
};

export enum SortType {
  Name,
  Cost,
  InitOrder,
  LastFire,
  NextFire,
  TickUsage,
  TickOverrun,
}

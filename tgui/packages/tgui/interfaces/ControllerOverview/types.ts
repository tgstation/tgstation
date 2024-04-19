import { BooleanLike } from 'common/react';

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
  tick_overrun: number;
  tick_usage: number;
};

export type ControllerData = {
  world_time: number;
  fast_update: BooleanLike;
  map_cpu: number;
  subsystems: SubsystemData[];
};

export enum SubsystemSortBy {
  NAME = 'Alphabetical',
  COST = 'Cost',
  INIT_ORDER = 'Init Order',
  LAST_FIRE = 'Last Fire',
  NEXT_FIRE = 'Next Fire',
  TICK_USAGE = 'Tick Usage',
  TICK_OVERRUN = 'Tick Overrun',
}

      // case SubsystemSortBy.INIT_ORDER:
      //   return input.init_order;
      // case SubsystemSortBy.NAME:
      //   return input.name.toLowerCase();
      // case SubsystemSortBy.LAST_FIRE:
      //   return input.last_fire;
      // case SubsystemSortBy.NEXT_FIRE:
      //   return input.next_fire;
      // case SubsystemSortBy.TICK_USAGE:
      //   return input.tick_usage;
      // case SubsystemSortBy.TICK_OVERRUN:
      //   return input.tick_overrun;
      // case SubsystemSortBy.COST:
      //   return input.cost_ms;

import { sortBy } from 'common/collections';

import { SubsystemData, SubsystemSortBy } from './types';

export function sortSubsystemBy(
  subsystems: SubsystemData[],
  sortType: SubsystemSortBy,
  ascending = true,
) {
  let sorted = sortBy(subsystems, (input: SubsystemData) => {
    switch (sortType) {
      case SubsystemSortBy.INIT_ORDER:
        return input.init_order;
      case SubsystemSortBy.NAME:
        return input.name.toLowerCase();
      case SubsystemSortBy.LAST_FIRE:
        return input.last_fire;
      case SubsystemSortBy.NEXT_FIRE:
        return input.next_fire;
      case SubsystemSortBy.TICK_USAGE:
        return input.tick_usage;
      case SubsystemSortBy.TICK_OVERRUN:
        return input.tick_overrun;
      case SubsystemSortBy.COST:
        return input.cost_ms;
    }
  });

  if (!ascending) {
    sorted.reverse();
  }
  return sorted;
}

type SortType = {
  label: string;
  propName: string;
  inDeciseconds: boolean;
};

export const SORTING_TYPES: readonly SortType[] = [
  {
    label: 'Alphabetical',
    propName: 'name',
    inDeciseconds: false,
  },
  {
    label: 'Cost',
    propName: 'cost_ms',
    inDeciseconds: true,
  },
  {
    label: 'Init Order',
    propName: 'init_order',
    inDeciseconds: false,
  },
  {
    label: 'Last Fire',
    propName: 'last_fire',
    inDeciseconds: false,
  },
  {
    label: 'Next Fire',
    propName: 'next_fire',
    inDeciseconds: false,
  },
  {
    label: 'Tick Usage',
    propName: 'tick_usage',
    inDeciseconds: true,
  },
  {
    label: 'Avg Usage Per Tick',
    propName: 'usage_per_tick',
    inDeciseconds: true,
  },
  {
    label: 'Tick Overrun',
    propName: 'tick_overrun',
    inDeciseconds: true,
  },
];

type SortType = {
  label: string;
  propName: string;
  useBars: boolean;
};

export const SORTING_TYPES: readonly SortType[] = [
  { label: 'Alphabetical', propName: 'name', useBars: false },
  { label: 'Cost', propName: 'cost_ms', useBars: true },
  { label: 'Init Order', propName: 'init_order', useBars: false },
  { label: 'Last Fire', propName: 'last_fire', useBars: false },
  { label: 'Next Fire', propName: 'next_fire', useBars: false },
  { label: 'Tick Usage', propName: 'tick_usage', useBars: true },
  { label: 'Tick Overrun', propName: 'tick_overrun', useBars: true },
];

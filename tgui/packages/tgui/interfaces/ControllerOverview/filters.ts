import { SortType } from './types';

export type FilterState = {
  ascending: boolean;
  inactive: boolean;
  query: string;
  smallValues: boolean;
  sortType: SortType;
};

export enum FilterAction {
  Ascending = 'SET_SORT_ASCENDING',
  Inactive = 'SET_FILTER_INACTIVE',
  SmallValues = 'SET_FILTER_SMALL_VALUES',
  SortType = 'SET_SORT_TYPE',
  Query = 'SET_FILTER_QUERY',
  Update = 'UPDATE_FILTER',
}

type Action =
  | { type: FilterAction.Ascending; payload: boolean }
  | { type: FilterAction.Inactive; payload: boolean }
  | { type: FilterAction.SmallValues; payload: boolean }
  | { type: FilterAction.SortType; payload: SortType }
  | { type: FilterAction.Query; payload: string }
  | { type: FilterAction.Update; payload: Partial<FilterState> };

export function filterReducer(state: FilterState, action: Action): FilterState {
  switch (action.type) {
    case FilterAction.Inactive:
      return { ...state, inactive: action.payload };
    case FilterAction.SmallValues:
      return { ...state, smallValues: action.payload };
    case FilterAction.Ascending:
      return { ...state, ascending: action.payload };
    case FilterAction.SortType:
      return { ...state, sortType: action.payload };
    case FilterAction.Query:
      return { ...state, query: action.payload };
    case FilterAction.Update:
      return { ...state, ...action.payload };
    default:
      return state;
  }
}

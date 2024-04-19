import { SubsystemSortBy } from './types';

export type FilterState = {
  ascending: boolean;
  inactive: boolean;
  name: string;
  smallValues: boolean;
  sortType: SubsystemSortBy;
};

export enum FilterAction {
  Inactive = 'SET_FILTER_INACTIVE',
  Name = 'SET_FILTER_NAME',
  SmallValues = 'SET_FILTER_SMALL_VALUES',
  Ascending = 'SET_SORT_ASCENDING',
  SortType = 'SET_SORT_TYPE',
}

type Action =
  | { type: FilterAction.Inactive; payload: boolean }
  | { type: FilterAction.Name; payload: string }
  | { type: FilterAction.SmallValues; payload: boolean }
  | { type: FilterAction.Ascending; payload: boolean }
  | { type: FilterAction.SortType; payload: SubsystemSortBy };

export function filterReducer(state: FilterState, action: Action): FilterState {
  switch (action.type) {
    case 'SET_FILTER_NAME':
      return { ...state, name: action.payload };
    case 'SET_SORT_TYPE':
      return { ...state, sortType: action.payload };
    case 'SET_SORT_ASCENDING':
      return { ...state, ascending: action.payload };
    case 'SET_FILTER_SMALL_VALUES':
      return { ...state, smallValues: action.payload };
    case 'SET_FILTER_INACTIVE':
      return { ...state, inactive: action.payload };
    default:
      return state;
  }
}

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'common/redux';
import { zustandStore } from '..';
import { selectDebug } from './selectors';

export const useDebug = (context) => {
  const newContext = {
    store: zustandStore,
  };
  return useSelector(newContext as any, selectDebug);
};

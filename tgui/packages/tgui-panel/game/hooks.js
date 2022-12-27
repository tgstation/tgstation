/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'common/redux';
import { selectGame } from './selectors';

export const useGame = (context) => {
  return useSelector(context, selectGame);
};

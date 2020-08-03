/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'tgui/store';
import { selectGameState } from './selectors';

export const useGameState = context => {
  return useSelector(context, selectGameState);
};

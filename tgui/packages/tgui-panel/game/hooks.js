/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'tgui/backend';
import { selectGame } from './selectors';

export const useGame = () => {
  return useSelector(selectGame);
};

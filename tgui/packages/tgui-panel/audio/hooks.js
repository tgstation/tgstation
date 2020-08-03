/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'tgui/store';
import { selectAudio } from './selectors';

export const useAudio = context => {
  return useSelector(context, selectAudio);
};

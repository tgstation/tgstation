/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'common/redux';
import { selectAudio } from './selectors';

export const useAudio = context => {
  return useSelector(context, selectAudio);
};

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector, useDispatch } from 'common/redux';
import { selectAudio } from './selectors';

export const useAudio = (context) => {
  const state = useSelector(context, selectAudio);
  const dispatch = useDispatch(context);
  return {
    ...state,
    toggle: () => dispatch({ type: 'audio/toggle' }),
  };
};

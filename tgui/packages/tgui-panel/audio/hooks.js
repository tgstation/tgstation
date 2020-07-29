import { useSelector } from 'tgui/store';
import { selectAudio } from './selectors';

export const useAudio = context => {
  return useSelector(context, selectAudio);
};

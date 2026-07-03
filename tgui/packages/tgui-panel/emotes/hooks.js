import { useAtom } from 'jotai';
import { emotesAtom } from './atom';

export const useEmotes = () => {
  const [emotes] = useAtom(emotesAtom);
  return emotes;
};

import { atom } from 'jotai';

export type Meta = {
  album: string;
  artist: string;
  duration: string;
  link: string;
  title: string;
  upload_date: string;
};

export const playingAtom = atom(false);
export const visibleAtom = atom(false);
export const metaAtom = atom<Meta | null>(null);

//------- Convenience --------------------------------------------------------//

export const audioAtom = atom((get) => ({
  playing: get(playingAtom),
  visible: get(visibleAtom),
  meta: get(metaAtom),
}));

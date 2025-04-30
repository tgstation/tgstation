import { create } from 'zustand';

type Meta = Partial<{
  album: string;
  artist: string;
  date: string;
  duration: string;
  link: string;
  title: string;
  upload_date: string;
}>;

type AudioState = {
  meta: Meta;
  playing: boolean;
  visible: boolean;
  track: string | null;
};

type Actions = {
  reset: () => void;
  start: (track: Meta) => void;
  toggle: () => void;
};

export const useAudioStore = create<AudioState & Actions>((set) => ({
  meta: {},
  playing: false,
  track: null,
  visible: false,

  reset: () =>
    set(() => ({
      meta: {},
      playing: false,
      track: null,
      visible: false,
    })),

  start: (song) =>
    set(() => ({
      meta: song,
      playing: true,
      track: song.link ?? null,
      visible: true,
    })),

  toggle: () =>
    set((state) => ({
      visible: !state.visible,
    })),
}));

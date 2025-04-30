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
  startMusic: (track: Meta) => void;
  stopMusic: () => void;
  toggle: () => void;
};

export const useAudioStore = create<AudioState & Actions>((set) => ({
  meta: {},
  playing: false,
  track: null,
  visible: false,

  startMusic: (song) =>
    set(() => ({
      meta: song,
      playing: true,
      track: song.link ?? null,
      visible: true,
    })),

  stopMusic: () =>
    set(() => ({
      meta: {},
      playing: false,
      track: null,
      visible: false,
    })),

  toggle: () =>
    set((state) => ({
      visible: !state.visible,
    })),
}));

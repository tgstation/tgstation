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
  setMeta: (meta: Meta) => void;
  setPlaying: (on: boolean) => void;
  stopMusic: () => void;
  toggle: () => void;
};

export const useAudioStore = create<AudioState & Actions>((set) => ({
  meta: {},
  playing: false,
  track: null,
  visible: false,

  setMeta: (meta) =>
    set(() => ({
      meta,
    })),

  setPlaying: (on) =>
    set(() => ({
      playing: on,
      visible: on,
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

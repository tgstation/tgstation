import { useShallow } from 'zustand/react/shallow';

import { useAudioStore } from '../events/stores/audio';

export function useAudio() {
  const meta = useAudioStore(useShallow((state) => state.meta));
  const playing = useAudioStore((state) => state.playing);
  const stopMusic = useAudioStore((state) => state.stopMusic);
  const toggle = useAudioStore((state) => state.toggle);
  const visible = useAudioStore((state) => state.visible);

  return {
    meta,
    playing,
    stopMusic,
    toggle,
    visible,
  };
}

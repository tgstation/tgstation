import { player } from '../../audio/NowPlayingWidget';
import { useAudioStore } from '../stores/audio';

type PlayPayload = {
  url: string;
} & Partial<{
  end: number;
  pitch: number;
  start: number;
}> &
  Record<string, any>;

export function playMusic(payload: PlayPayload) {
  const { url, ...options } = payload;

  player.play(url, options);
  useAudioStore.getState().startMusic({
    link: url,
    ...options,
  });
}

export function stopMusic() {
  player.stop();
  useAudioStore.getState().stopMusic();
}

export function handleVolumeUpdate(volume: number | undefined) {
  if (typeof volume === 'number') {
    player.setVolume(volume);
  }
}

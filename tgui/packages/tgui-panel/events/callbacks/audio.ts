import { player } from '../../audio/NowPlayingWidget';
import { useAudioStore } from '../stores/audio';

type PlayPayload = {
  url: string;
} & Record<string, any>;

export function handleVolumeUpdate(volume: number | undefined) {
  if (typeof volume === 'number') {
    player.setVolume(volume);
  }
}

export function playMusic(payload: PlayPayload) {
  const { url, ...options } = payload;

  player.play(url, options);
  useAudioStore.getState().start({
    link: url,
    ...options,
  });
}

export function resetMusic() {
  useAudioStore.getState().reset();
}

export function stopMusic() {
  player.stop();
}

import { player } from '../../audio/NowPlayingWidget';

type PlayPayload = {
  url: string;
} & Record<string, any>;

export function playMusic(payload: PlayPayload) {
  const { url, ...options } = payload;

  player.play(url, options);
}

export function stopMusic() {
  player.stop();
}

export function handleVolumeUpdate(volume: number | undefined) {
  if (typeof volume === 'number') {
    player.setVolume(volume);
  }
}

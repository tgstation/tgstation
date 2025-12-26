import { store } from '../events/store';
import { type Meta, metaAtom, playingAtom, visibleAtom } from './atoms';
import { AudioPlayer } from './player';

export const player = new AudioPlayer();

player.onPlay(() => {
  store.set(playingAtom, true);
  store.set(visibleAtom, true);
});

player.onStop(() => {
  store.set(playingAtom, false);
  store.set(visibleAtom, false);
  store.set(metaAtom, null);
});

type PlayPayload = {
  url: string;
  pitch: number;
  start: number;
  end: number;
} & Meta;

export function playMusic(payload: PlayPayload): void {
  const { url, ...options } = payload;

  player.play(url, options);
  store.set(metaAtom, options);
}

export function stopMusic(): void {
  player.stop();
}

// settings/update and settings/load
export function setMusicVolume(volume: number): void {
  player.setVolume(volume);
}

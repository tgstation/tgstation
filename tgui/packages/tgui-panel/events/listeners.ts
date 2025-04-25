import { playMusic, stopMusic } from './callbacks/audio';

export const listeners = {
  'audio/playMusic': playMusic,
  'audio/stopMusic': stopMusic,
} as const;

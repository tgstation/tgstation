/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';

import { resetMusic } from '../events/callbacks/audio';

const logger = createLogger('AudioPlayer');

type AudioOptions = Partial<{
  pitch: number;
  start: number;
  end: number;
}>;

function isProtected(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'isTrusted' in error &&
    (error as Event).isTrusted === true
  );
}

export class AudioPlayer {
  element: HTMLAudioElement | null;
  options: AudioOptions;
  volume: number;

  constructor() {
    this.element = null;
  }

  destroy(): void {
    this.element = null;
  }

  play(url: string, options: AudioOptions = {}): void {
    if (this.element) {
      this.stop();
    }

    this.options = options;
    const audio = new Audio(url);
    if (!audio) {
      logger.log('failed to create audio element');
      resetMusic();
      return;
    }

    this.element = audio;

    audio.volume = this.volume;
    audio.playbackRate = this.options.pitch || 1;

    logger.log('playing', url, options);

    audio.addEventListener('ended', () => {
      logger.log('ended');
      this.stop();
    });

    audio.addEventListener('error', (error) => {
      if (isProtected(error)) {
        logger.log('audio appears to be protected');
      } else {
        logger.log('audio playback error', JSON.stringify(error));
      }
      this.stop();
    });

    if (this.options.end) {
      audio.addEventListener('timeupdate', () => {
        if (
          this.options.end &&
          this.options.end > 0 &&
          audio.currentTime >= this.options.end
        ) {
          this.stop();
        }
      });
    }

    audio.play()?.catch(() => logger.log('playback error'));
  }

  stop(): void {
    if (!this.element) return;

    logger.log('stopping');

    this.element.pause();
    this.destroy();

    resetMusic();
  }

  setVolume(volume: number): void {
    this.volume = volume;

    if (!this.element) return;

    this.element.volume = volume;
  }
}

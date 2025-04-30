/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';

const logger = createLogger('AudioPlayer');

type AudioOptions = {
  pitch?: number;
  start?: number;
  end?: number;
};

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
    this.element = new Audio(url);

    const audio = this.element;
    if (!audio) return;

    audio.volume = this.volume;
    audio.playbackRate = this.options.pitch || 1;

    logger.log('playing', url, options);

    audio.addEventListener('ended', () => {
      logger.log('ended');
      this.stop();
    });

    audio.addEventListener('error', (error) => {
      logger.log('playback error', error);
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

    audio.play()?.catch((error) => logger.log('playback error', error));
  }

  stop(): void {
    if (!this.element) return;

    logger.log('stopping');

    this.element.pause();
    this.element = null;
  }

  setVolume(volume: number): void {
    this.volume = volume;

    if (!this.element) return;

    this.element.volume = volume;
  }
}

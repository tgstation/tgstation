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

function isProtectedError(error: ErrorEvent): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'isTrusted' in error &&
    error.isTrusted
  );
}

export class AudioPlayer {
  element: HTMLAudioElement | null;
  options: AudioOptions;
  volume: number;

  onPlaySubscribers: (() => void)[];
  onStopSubscribers: (() => void)[];

  constructor() {
    this.element = null;

    this.onPlaySubscribers = [];
    this.onStopSubscribers = [];
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
      if (isProtectedError(error)) {
        Byond.sendMessage('audio/protected');
      }
      logger.log('playback error:', JSON.stringify(error));
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

    audio.play()?.catch(() => {
      // no error is passed here, it's sent to the event listener
      logger.log('playback failed');
    });

    this.onPlaySubscribers.forEach((subscriber) => subscriber());
  }

  stop(): void {
    if (!this.element) return;

    logger.log('stopping');

    this.element.pause();
    this.destroy();

    this.onStopSubscribers.forEach((subscriber) => subscriber());
  }

  setVolume(volume: number): void {
    this.volume = volume;

    if (!this.element) return;

    this.element.volume = volume;
  }

  onPlay(subscriber: () => void): void {
    this.onPlaySubscribers.push(subscriber);
  }

  onStop(subscriber: () => void): void {
    this.onStopSubscribers.push(subscriber);
  }
}

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';

const logger = createLogger('AudioPlayer');

export class AudioPlayer {
  constructor() {
    // Doesn't support HTMLAudioElement
    if (Byond.IS_LTE_IE9) {
      return;
    }
    // Set up the HTMLAudioElement node
    this.node = document.createElement('audio');
    this.node.style.setProperty('display', 'none');
    document.body.appendChild(this.node);
    // Set up other properties
    this.playing = false;
    this.volume = 1;
    this.options = {};
    this.onPlaySubscribers = [];
    this.onStopSubscribers = [];
    // Listen for playback start events
    this.node.addEventListener('canplaythrough', () => {
      logger.log('canplaythrough');
      this.playing = true;
      this.node.playbackRate = this.options.pitch || 1;
      this.node.currentTime = this.options.start || 0;
      this.node.volume = this.volume;
      this.node.play();
      for (let subscriber of this.onPlaySubscribers) {
        subscriber();
      }
    });
    // Listen for playback stop events
    this.node.addEventListener('ended', () => {
      logger.log('ended');
      this.stop();
    });
    // Listen for playback errors
    this.node.addEventListener('error', e => {
      if (this.playing) {
        logger.log('playback error', e.error);
        this.stop();
      }
    });
    // Check every second to stop the playback at the right time
    this.playbackInterval = setInterval(() => {
      if (!this.playing) {
        return;
      }
      const shouldStop = this.options.end > 0
        && this.node.currentTime >= this.options.end;
      if (shouldStop) {
        this.stop();
      }
    }, 1000);
  }

  destroy() {
    if (!this.node) {
      return;
    }
    this.node.stop();
    document.removeChild(this.node);
    clearInterval(this.playbackInterval);
  }

  play(url, options = {}) {
    if (!this.node) {
      return;
    }
    logger.log('playing', url, options);
    this.options = options;
    this.node.src = url;
  }

  stop() {
    if (!this.node) {
      return;
    }
    if (this.playing) {
      for (let subscriber of this.onStopSubscribers) {
        subscriber();
      }
    }
    logger.log('stopping');
    this.playing = false;
    this.node.src = '';
  }

  setVolume(volume) {
    if (!this.node) {
      return;
    }
    this.volume = volume;
    this.node.volume = volume;
  }

  onPlay(subscriber) {
    if (!this.node) {
      return;
    }
    this.onPlaySubscribers.push(subscriber);
  }

  onStop(subscriber) {
    if (!this.node) {
      return;
    }
    this.onStopSubscribers.push(subscriber);
  }
}

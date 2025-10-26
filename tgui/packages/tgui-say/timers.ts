import { debounce, throttle } from 'tgui-core/timer';

import type { Channel } from './ChannelIterator';

const SECONDS = 1000;

/** Timers: Prevents overloading the server, throttles messages */
export const byondMessages = {
  // Debounce: Prevents spamming the server
  channelIncrementMsg: debounce(
    (visible: boolean) => Byond.sendMessage('thinking', { visible }),
    0.4 * SECONDS,
  ),
  forceSayMsg: debounce(
    (entry: string, channel: Channel) =>
      Byond.sendMessage('force', { entry, channel }),
    1 * SECONDS,
    true,
  ),
  saveText: debounce(
    (entry: string, channel: Channel) =>
      Byond.sendMessage('save', { entry, channel }),
    1 * SECONDS,
    true,
  ),
  // Throttle: Prevents spamming the server
  typingMsg: throttle(() => Byond.sendMessage('typing'), 4 * SECONDS),
} as const;

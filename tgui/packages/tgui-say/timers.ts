import { debounce, throttle } from 'common/timer';

const SECONDS = 1000;

/** Timers: Prevents overloading the server, throttles messages */
export const byondMessages = {
  // Debounce: Prevents spamming the server
  channelIncrementMsg: debounce(
    (visible: boolean) => Byond.sendMessage('thinking', { visible }),
    0.4 * SECONDS
  ),
  forceSayMsg: debounce(
    (entry: string) => Byond.sendMessage('force', { entry, channel: 'Say' }),
    1 * SECONDS,
    true
  ),
  // Throttle: Prevents spamming the server
  typingMsg: throttle(() => Byond.sendMessage('typing'), 4 * SECONDS),
} as const;

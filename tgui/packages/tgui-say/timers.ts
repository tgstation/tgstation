import { debounce, throttle } from 'common/timer';

const SECONDS = 1000;

/** Timers: Prevents overloading the server, throttles messages */
export const timers = {
  // Debounce: Prevents spamming the server
  onChannelIncrement: debounce(
    (visible: boolean) => Byond.sendMessage('thinking', visible),
    0.4 * SECONDS
  ),
  onForceSay: debounce(
    (entry: string) => Byond.sendMessage('force', entry),
    1 * SECONDS,
    true
  ),
  // Throttle: Prevents spamming the server
  onTyping: throttle(() => Byond.sendMessage('typing'), 4 * SECONDS),
} as const;

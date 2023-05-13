import { debounce, throttle } from 'common/timer';
import { Modal } from './types';

/** Timers: Prevents overloading the server, throttles messages */
export const timers: Modal['timers'] = {
  channelDebounce: debounce(
    (mode: string) => Byond.sendMessage('thinking', mode),
    400
  ),
  forceDebounce: debounce(
    (entry: string) => Byond.sendMessage('force', entry),
    1000,
    true
  ),
  typingThrottle: throttle(() => Byond.sendMessage('typing'), 4000),
};

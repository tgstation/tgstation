import { configAtom, store } from './events/store';
import { logger } from './logging';

/**
 * Creates a function, which can be assigned to window.__augmentStack__
 * to augment reported stack traces with useful data for debugging.
 */
export const createStackAugmentor =
  () =>
  (stack: string, error?: Error): string => {
    error = error || new Error(stack.split('\n')[0]);
    error.stack = error.stack || stack;

    logger.log('FatalError:', error);
    const config = store.get(configAtom);

    return (
      stack +
      '\nUser Agent: ' +
      navigator.userAgent +
      '\nState: ' +
      JSON.stringify({
        ckey: config?.client?.ckey,
        interface: config?.interface,
        window: config?.window,
      })
    );
  };

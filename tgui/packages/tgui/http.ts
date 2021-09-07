import { FetchOptions } from "jsdom";

/**
 * An equivalent to `fetch`, except will automatically retry.
 */
export const fetchRetry
  = (
    url: string,
    options?: FetchOptions,
    retryTimer: number = 1000,
  ): Promise<Response> => {
    return fetch(url, options).catch(() => {
      return new Promise(resolve => {
        setTimeout(() => {
          fetchRetry(url, options, retryTimer).then(resolve);
        }, retryTimer);
      });
    });
  };

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createAction } from 'common/redux';

export const pingSuccess = createAction(
  'ping/success',
  ping => {
    const now = Date.now();
    const roundtrip = (now - ping.sentAt) * 0.5;
    return {
      payload: {
        lastId: ping.id,
        roundtrip,
      },
      meta: { now },
    };
  }
);

export const pingFail = createAction('ping/fail');
export const pingReply = createAction('ping/reply');

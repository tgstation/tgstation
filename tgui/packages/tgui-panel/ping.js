import { sendMessage } from "tgui/backend";
import { logger } from "tgui/logging";

export const selectPing = state => state?.ping || {};

const updatePingState = ping => ({
  type: 'ping/update',
  payload: {
    time: Date.now() - ping.sentAt,
    lastId: ping.id,
  },
});

export const pingReducer = (state = {}, action) => {
  const { type, payload } = action;
  if (type === 'ping/update') {
    return payload;
  }
  return state;
};

export const pingMiddleware = store => {
  let id = 0;
  let pings = [];
  setInterval(() => {
    logger.log('pings.length', pings.length);
    id++;
    const ping = { id, sentAt: Date.now() };
    logger.log(ping);
    pings.push(ping);
    sendMessage({
      type: 'ping',
      payload: { id },
    });
  }, 2000);
  return next => action => {
    const { type, payload } = action;
    if (type === 'pingReply') {
      const pingIndex = pings.findIndex(ping => ping.id === payload.id);
      if (pingIndex < 0) {
        logger.log('could not find the ping!');
        return;
      }
      const ping = pings[pingIndex];
      pings.splice(pingIndex, 1);
      return next(updatePingState(ping));
    }
    return next(action);
  };
};

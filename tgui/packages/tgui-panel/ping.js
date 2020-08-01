import { Color } from 'common/color';
import { clamp01, scale } from 'common/math';
import { sendMessage } from 'tgui/backend';
import { Box } from 'tgui/components';
import { logger } from 'tgui/logging';
import { useSelector } from 'tgui/store';

const PING_INTERVAL = 2500;
const PING_TIMEOUT = 2000;
const PING_MAX_FAILS = 3;
const PING_QUEUE_SIZE = 8;
const PING_ROUNDTRIP_BEST = 40;
const PING_ROUNDTRIP_WORST = 120;

export const selectPing = state => state?.ping || {};

const pingSuccess = ping => {
  const roundtrip = (Date.now() - ping.sentAt) * 0.5;
  return {
    type: 'ping/success',
    payload: {
      lastId: ping.id,
      roundtrip,
    },
  };
};

const pingFail = () => ({
  type: 'ping/fail',
});

export const pingReducer = (state = {}, action) => {
  const { type, payload } = action;
  if (type === 'ping/success') {
    const { roundtrip } = payload;
    const prevRoundtrip = state.roundtripAvg || roundtrip;
    const roundtripAvg = Math.round(prevRoundtrip * 0.4 + roundtrip * 0.6);
    const networkQuality = 1 - scale(roundtripAvg,
      PING_ROUNDTRIP_BEST, PING_ROUNDTRIP_WORST);
    return {
      roundtrip,
      roundtripAvg,
      failCount: 0,
      networkQuality,
    };
  }
  if (type === 'ping/fail') {
    const { failCount = 0 } = state;
    const networkQuality = clamp01(state.networkQuality
      - failCount / PING_MAX_FAILS);
    const nextState = {
      ...state,
      failCount: failCount + 1,
      networkQuality,
    };
    if (failCount > PING_MAX_FAILS) {
      nextState.roundtrip = undefined;
      nextState.roundtripAvg = undefined;
    }
    return nextState;
  }
  return state;
};

export const pingMiddleware = store => {
  let initialized = false;
  let index = 0;
  const pings = [];
  const sendPing = () => {
    for (let i = 0; i < PING_QUEUE_SIZE; i++) {
      const ping = pings[i];
      if (ping && Date.now() - ping.sentAt > PING_TIMEOUT) {
        pings[i] = null;
        store.dispatch(pingFail());
      }
    }
    const ping = { index, sentAt: Date.now() };
    pings[index] = ping;
    sendMessage({
      type: 'ping',
      payload: { index },
    });
    index = (index + 1) % PING_QUEUE_SIZE;
  };
  return next => action => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      setInterval(sendPing, PING_INTERVAL);
      sendPing();
    }
    if (type === 'pingReply') {
      const { index } = payload;
      const ping = pings[index];
      if (!ping) {
        logger.log('Received a timed out ping.');
        return;
      }
      pings[index] = null;
      return next(pingSuccess(ping));
    }
    return next(action);
  };
};

export const PingIndicator = (props, context) => {
  const ping = useSelector(context, selectPing);
  return (
    <Box
      px={1} py={0.5}
      style={{
        'border-radius': '0.25em',
      }}
      backgroundColor="black"
      textColor={Color.lookup(ping.networkQuality, [
        new Color(240, 60, 60),
        new Color(240, 220, 40),
        new Color(40, 240, 80),
      ])}>
      {ping.roundtripAvg || '--'} ms
    </Box>
  );
};

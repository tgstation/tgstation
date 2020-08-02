import { createAction } from 'common/redux';
import { subscribeToHotKey } from '../hotkeys';

export const openExternalBrowser = createAction('debug/openExternalBrowser');

const relayedTypes = [
  'backend/update',
  'chat/message',
];

export const relayMiddleware = store => {
  const devServer = require('tgui-dev-server/link/client');
  const externalBrowser = location.search === '?external';
  let initialized = false;
  if (externalBrowser) {
    devServer.subscribe(msg => {
      const { type, payload } = msg;
      if (type === 'relay' && payload.windowId === window.__windowId__) {
        store.dispatch({
          ...payload.action,
          relayed: true,
        });
      }
    });
  }
  return next => action => {
    const { type, payload, relayed } = action;
    if (!initialized) {
      initialized = true;
      if (!externalBrowser) {
        subscribeToHotKey('F10', () => openExternalBrowser());
      }
      return next(action);
    }
    if (type === openExternalBrowser.type) {
      window.open(location.href + '?external', '_blank');
      return;
    }
    if (relayedTypes.includes(type) && !relayed && !externalBrowser) {
      devServer.sendMessage({
        type: 'relay',
        payload: {
          windowId: window.__windowId__,
          action,
        },
      });
    }
    return next(action);
  };
};

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Polyfills
import 'core-js/es';
import 'core-js/web/immediate';
import 'core-js/web/queue-microtask';
import 'core-js/web/timers';
import 'regenerator-runtime/runtime';
import 'tgui/polyfills/html5shiv';
import 'tgui/polyfills/ie8';
import 'tgui/polyfills/dom4';
import 'tgui/polyfills/css-om';
import 'tgui/polyfills/inferno';

// Themes
import './styles/main.scss';
import './styles/themes/light.scss';

import { perf } from 'common/perf';
import { combineReducers } from 'common/redux';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { createRenderer } from 'tgui/renderer';
import { configureStore, StoreProvider } from 'tgui/store';
import { audioMiddleware, audioReducer } from './audio';
import { chatMiddleware, chatReducer } from './chat';
import { pingMiddleware, pingReducer } from './ping';
import { settingsMiddleware, settingsReducer } from './settings';
import { telemetryMiddleware } from './telemetry';
import { setupExternalLinkCapturing } from 'tgui/external-links';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const store = configureStore({
  reducer: combineReducers({
    audio: audioReducer,
    chat: chatReducer,
    ping: pingReducer,
    settings: settingsReducer,
  }),
  middleware: {
    pre: [
      chatMiddleware,
      pingMiddleware,
      telemetryMiddleware,
      settingsMiddleware,
      audioMiddleware,
    ],
  },
});

const renderApp = createRenderer(() => {
  const { Panel } = require('./Panel');
  return (
    <StoreProvider store={store}>
      <Panel />
    </StoreProvider>
  );
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  // Subscribe for Redux state updates
  store.subscribe(renderApp);

  // Capture external links
  setupExternalLinkCapturing();

  // Subscribe for bankend updates
  window.update = msg => store.dispatch(Byond.parseJson(msg));

  // Process the early update queue
  while (true) {
    const msg = window.__updateQueue__.shift();
    if (!msg) {
      break;
    }
    window.update(msg);
  }

  // Unhide the panel
  Byond.winset('output', {
    'is-visible': false,
  });
  Byond.winset('browseroutput', {
    'is-visible': true,
    'is-disabled': false,
    'pos': '0x0',
    'size': '0x0',
  });

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept([
      './audio',
      './chat',
      './Panel',
      './ping',
      './settings',
      './telemetry',
    ], () => {
      renderApp();
    });
  }
};

setupApp();

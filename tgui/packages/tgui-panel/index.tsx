/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';
import './styles/themes/light.scss';

import { perf } from 'common/perf';
import { combineReducers } from 'common/redux';
import { setGlobalStore } from 'tgui/backend';
import { captureExternalLinks } from 'tgui/links';
import { render } from 'tgui/renderer';
import { configureStore } from 'tgui/store';
import { setupGlobalEvents } from 'tgui-core/events';
import { setupHotReloading } from 'tgui-dev-server/link/client';

import { audioMiddleware, audioReducer } from './audio';
import { chatMiddleware, chatReducer } from './chat';
import { gameMiddleware, gameReducer } from './game';
import { Panel } from './Panel';
import { setupPanelFocusHacks } from './panelFocus';
import { pingMiddleware, pingReducer } from './ping';
import { settingsMiddleware, settingsReducer } from './settings';
import { telemetryMiddleware } from './telemetry';

perf.mark('inception', window.performance?.timeOrigin);
perf.mark('init');

const store = configureStore({
  reducer: combineReducers({
    audio: audioReducer,
    chat: chatReducer,
    game: gameReducer,
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
      gameMiddleware,
    ],
  },
});

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setGlobalStore(store);

  setupGlobalEvents({
    ignoreWindowFocus: true,
  });

  setupPanelFocusHacks();
  captureExternalLinks();

  // Re-render UI on store updates
  store.subscribe(() => render(<Panel />));

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Unhide the panel
  Byond.winset('output_selector.legacy_output_selector', {
    left: 'output_browser',
  });

  // Resize the panel to match the non-browser output
  Byond.winget('output').then((output: { size: string }) => {
    Byond.winset('browseroutput', {
      size: output.size,
    });
  });

  // Enable hot module reloading
  if (import.meta.webpackHot) {
    setupHotReloading();

    import.meta.webpackHot.accept(
      [
        './audio',
        './chat',
        './game',
        './Notifications',
        './Panel',
        './ping',
        './settings',
        './telemetry',
      ],
      () => {
        render(<Panel />);
      },
    );
  }
}

setupApp();

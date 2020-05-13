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
import './polyfills/html5shiv';
import './polyfills/ie8';
import './polyfills/dom4';
import './polyfills/css-om';
import './polyfills/inferno';

// Themes
import './styles/main.scss';
import './styles/themes/cardtable.scss';
import './styles/themes/malfunction.scss';
import './styles/themes/ntos.scss';
import './styles/themes/hackerman.scss';
import './styles/themes/retro.scss';
import './styles/themes/syndicate.scss';

import { render } from 'inferno';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { loadCSS } from './assets';
import { backendUpdate, backendSuspend } from './backend';
import { IS_IE8, callByond } from './byond';
import { setupDrag } from './drag';
import { logger } from './logging';
import { createStore, StoreProvider } from './store';

const enteredBundleAt = Date.now();
const store = createStore();
let reactRoot;
let initialRender = true;

const renderLayout = () => {
  // Mark the beginning of the render
  let startedAt;
  let finishedAt;
  if (process.env.NODE_ENV !== 'production') {
    startedAt = Date.now();
  }
  const state = store.getState();
  try {
    // Initial render setup
    if (initialRender) {
      logger.error('initial render config', state.config);
      logger.log('initial render', state);
      // Setup dragging
      if (initialRender !== 'recycled') {
        setupDrag(state);
      }
    }
    // Start rendering
    const { getRoutedComponent } = require('./routes');
    const Component = getRoutedComponent(state);
    const element = (
      <StoreProvider store={store}>
        <Component />
      </StoreProvider>
    );
    if (!reactRoot) {
      reactRoot = document.getElementById('react-root');
    }
    render(element, reactRoot);
    if (state.suspended) {
      return;
    }
    if (initialRender) {
      // We schedule for the next tick here because resizing and unhiding
      // during the same tick will flash with a white background.
      setImmediate(() => {
        // Doublecheck if we are suspended, because state might have changed.
        const state = store.getState();
        if (state.suspended) {
          return;
        }
        callByond('winset', {
          id: window.__windowId__,
          'is-visible': true,
        });
        logger.log('visible in', timeDiff(finishedAt, Date.now()));
      });
    }
  }
  catch (err) {
    logger.error('rendering error', err);
    throw err;
  }
  // Report rendering time
  if (process.env.NODE_ENV !== 'production') {
    finishedAt = Date.now();
    if (initialRender === 'recycled') {
      logger.log('rendered in', timeDiff(startedAt, finishedAt));
    }
    else if (initialRender) {
      logger.debug('serving from:', location.href);
      logger.debug('bundle entered in', timeDiff(
        window.__inception__, enteredBundleAt));
      logger.debug('initialized in', timeDiff(enteredBundleAt, startedAt));
      logger.log('rendered in', timeDiff(startedAt, finishedAt));
      logger.log('fully loaded in', timeDiff(
        window.__inception__, finishedAt));
    }
    else {
      logger.debug('rendered in', timeDiff(startedAt, finishedAt));
    }
  }
  if (initialRender) {
    initialRender = false;
  }
  // Load assets
  state.assets?.styles?.forEach(filename => loadCSS(filename));
};

const timeDiff = (startedAt, finishedAt) => {
  const diff = finishedAt - startedAt;
  const diffFrames = (diff / 16.6667).toFixed(2);
  return `${diff}ms (${diffFrames} frames)`;
};

// Parse JSON and report all abnormal JSON strings coming from BYOND
const parseStateJson = json => {
  let reviver = (key, value) => {
    if (typeof value === 'object' && value !== null) {
      if (value.__number__) {
        return parseFloat(value.__number__);
      }
    }
    return value;
  };
  // IE8: No reviver for you!
  // See: https://stackoverflow.com/questions/1288962
  if (IS_IE8) {
    reviver = undefined;
  }
  try {
    return JSON.parse(json, reviver);
  }
  catch (err) {
    logger.log(err);
    logger.log('What we got:', json);
    const msg = err && err.message;
    throw new Error('JSON parsing error: ' + msg);
  }
};

const setupApp = () => {
  // Subscribe for redux state updates
  store.subscribe(() => {
    renderLayout();
  });

  // Subscribe for bankend updates
  window.update = stateJson => {
    logger.debug(`window.update (${window.__windowId__})`);
    const prevState = store.getState();
    // NOTE: stateJson can be an object only if called manually from console.
    // This is useful for debugging tgui in external browsers, like Chrome.
    const nextState = typeof stateJson === 'string'
      ? parseStateJson(stateJson)
      : stateJson;

    if (prevState.suspended) {
      logger.log('reinitializing to:', nextState.config.ref);
      window.__ref__ = nextState.config.ref;
      initialRender = 'recycled';
    }

    // Backend update dispatches a store action
    store.dispatch(backendUpdate(nextState));
  };

  window.suspend = () => {
    logger.log(`suspending (${window.__windowId__})`);
    callByond('winset', {
      id: window.__windowId__,
      'is-visible': false,
    });
    store.dispatch(backendSuspend());
  };

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept([
      './components',
      './layouts',
      './routes',
    ], () => {
      renderLayout();
    });
  }

  // Process the early update queue
  while (true) {
    let stateJson = window.__updateQueue__.shift();
    if (!stateJson) {
      break;
    }
    window.update(stateJson);
  }

  // Dynamically load font-awesome from browser's cache
  loadCSS('font-awesome.css');
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', setupApp);
}
else {
  setupApp();
}

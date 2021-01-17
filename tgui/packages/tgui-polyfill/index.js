/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import 'core-js/es';
import 'core-js/web/immediate';
import 'core-js/web/queue-microtask';
import 'core-js/web/timers';
import 'regenerator-runtime/runtime';
import './html5shiv';
import './ie8';
import './dom4';
import './css-om';
import './inferno';

// Fetch is required for Webpack HMR
if (module.hot) {
  require('whatwg-fetch');
}

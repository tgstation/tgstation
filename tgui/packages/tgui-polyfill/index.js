/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// NOTE: There are numbered polyfills, which are baked and injected directly
// into `tgui.html`. See how they're baked in `package.json`.

import 'core-js/es';
import 'core-js/web/immediate';
import 'core-js/web/queue-microtask';
import 'core-js/web/timers';
import 'regenerator-runtime/runtime';
import 'unfetch/polyfill';

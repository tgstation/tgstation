/**
 * Basically, hacks from goonchat which try to keep the map focused at all
 * times, except for when some meaningful action happens o
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { vecLength, vecSubtract } from 'common/vector';
import { focusMap } from 'tgui/focus';
import { canStealFocus, globalEvents } from 'tgui-core/events';

// Empyrically determined number for the smallest possible
// text you can select with the mouse.
const MIN_SELECTION_DISTANCE = 10;

const deferredFocusMap = () => setTimeout(() => focusMap());

export const setupPanelFocusHacks = () => {
  let focusStolen = false;
  let clickStartPos = null;
  window.addEventListener('focusin', (e) => {
    focusStolen = canStealFocus(e.target);
  });
  window.addEventListener('mousedown', (e) => {
    clickStartPos = [e.screenX, e.screenY];
  });
  window.addEventListener('mouseup', (e) => {
    if (clickStartPos) {
      const clickEndPos = [e.screenX, e.screenY];
      const dist = vecLength(vecSubtract(clickEndPos, clickStartPos));
      if (dist >= MIN_SELECTION_DISTANCE) {
        focusStolen = true;
      }
    }
    if (!focusStolen) {
      deferredFocusMap();
    }
  });
  globalEvents.on('keydown', (key) => {
    if (key.isModifierKey()) {
      return;
    }
    deferredFocusMap();
  });
};

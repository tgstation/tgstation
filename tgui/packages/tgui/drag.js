/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { vecAdd, vecInverse, vecMultiply, vecScale } from 'common/vector';
import { createLogger } from './logging';

const logger = createLogger('drag');

let windowKey = window.__windowId__;
let dragging = false;
let resizing = false;
let screenOffset = [0, 0];
let screenOffsetPromise;
let dragPointOffset;
let resizeMatrix;
let initialSize;
let size;

export const setWindowKey = key => {
  windowKey = key;
};

export const getWindowPosition = () => [
  window.screenLeft,
  window.screenTop,
];

export const getWindowSize = () => [
  window.innerWidth,
  window.innerHeight,
];

export const setWindowPosition = vec => {
  const byondPos = vecAdd(vec, screenOffset);
  return Byond.winset(window.__windowId__, {
    pos: byondPos[0] + ',' + byondPos[1],
  });
};

export const setWindowSize = vec => {
  return Byond.winset(window.__windowId__, {
    size: vec[0] + 'x' + vec[1],
  });
};

export const getScreenPosition = () => [
  0 - screenOffset[0],
  0 - screenOffset[1],
];

export const getScreenSize = () => [
  window.screen.availWidth,
  window.screen.availHeight,
];

/**
 * Moves an item to the top of the recents array, and keeps its length
 * limited to the number in `limit` argument.
 *
 * Uses a strict equality check for comparisons.
 *
 * Returns new recents and an item which was trimmed.
 */
const touchRecents = (recents, touchedItem, limit = 50) => {
  const nextRecents = [touchedItem];
  let trimmedItem;
  for (let i = 0; i < recents.length; i++) {
    const item = recents[i];
    if (item === touchedItem) {
      continue;
    }
    if (nextRecents.length < limit) {
      nextRecents.push(item);
    }
    else {
      trimmedItem = item;
    }
  }
  return [nextRecents, trimmedItem];
};

export const storeWindowGeometry = async () => {
  logger.log('storing geometry');
  const geometry = {
    pos: getWindowPosition(),
    size: getWindowSize(),
  };
  storage.set(windowKey, geometry);
  // Update the list of stored geometries
  const [geometries, trimmedKey] = touchRecents(
    await storage.get('geometries') || [],
    windowKey);
  if (trimmedKey) {
    storage.remove(trimmedKey);
  }
  storage.set('geometries', geometries);
};

export const recallWindowGeometry = async (options = {}) => {
  // Only recall geometry in fancy mode
  const geometry = options.fancy && await storage.get(windowKey);
  if (geometry) {
    logger.log('recalled geometry:', geometry);
  }
  let pos = geometry?.pos || options.pos;
  const size = options.size;
  // Set window size
  if (size) {
    setWindowSize(size);
  }
  // Set window position
  if (pos) {
    await screenOffsetPromise;
    // Constraint window position if monitor lock was set in preferences.
    if (size && options.locked) {
      pos = constraintPosition(pos, size)[1];
    }
    setWindowPosition(pos);
  }
  // Set window position at the center of the screen.
  else if (size) {
    await screenOffsetPromise;
    const areaAvailable = [
      window.screen.availWidth - Math.abs(screenOffset[0]),
      window.screen.availHeight - Math.abs(screenOffset[1]),
    ];
    const pos = vecAdd(
      vecScale(areaAvailable, 0.5),
      vecScale(size, -0.5),
      vecScale(screenOffset, -1.0));
    setWindowPosition(pos);
  }
};

export const setupDrag = async () => {
  // Calculate screen offset caused by the windows taskbar
  screenOffsetPromise = Byond.winget(window.__windowId__, 'pos')
    .then(pos => [
      pos.x - window.screenLeft,
      pos.y - window.screenTop,
    ]);
  screenOffset = await screenOffsetPromise;
  logger.debug('screen offset', screenOffset);
};

/**
 * Constraints window position to safe screen area, accounting for safe
 * margins which could be a system taskbar.
 */
const constraintPosition = (pos, size) => {
  const screenPos = getScreenPosition();
  const screenSize = getScreenSize();
  const nextPos = [pos[0], pos[1]];
  let relocated = false;
  for (let i = 0; i < 2; i++) {
    const leftBoundary = screenPos[i];
    const rightBoundary = screenPos[i] + screenSize[i];
    if (pos[i] < leftBoundary) {
      nextPos[i] = leftBoundary;
      relocated = true;
    }
    else if (pos[i] + size[i] > rightBoundary) {
      nextPos[i] = rightBoundary - size[i];
      relocated = true;
    }
  }
  return [relocated, nextPos];
};

export const dragStartHandler = event => {
  logger.log('drag start');
  dragging = true;
  dragPointOffset = [
    window.screenLeft - event.screenX,
    window.screenTop - event.screenY,
  ];
  // Focus click target
  event.target?.focus();
  document.addEventListener('mousemove', dragMoveHandler);
  document.addEventListener('mouseup', dragEndHandler);
  dragMoveHandler(event);
};

const dragEndHandler = event => {
  logger.log('drag end');
  dragMoveHandler(event);
  document.removeEventListener('mousemove', dragMoveHandler);
  document.removeEventListener('mouseup', dragEndHandler);
  dragging = false;
  storeWindowGeometry();
};

const dragMoveHandler = event => {
  if (!dragging) {
    return;
  }
  event.preventDefault();
  setWindowPosition(vecAdd(
    [event.screenX, event.screenY],
    dragPointOffset));
};

export const resizeStartHandler = (x, y) => event => {
  resizeMatrix = [x, y];
  logger.log('resize start', resizeMatrix);
  resizing = true;
  dragPointOffset = [
    window.screenLeft - event.screenX,
    window.screenTop - event.screenY,
  ];
  initialSize = [
    window.innerWidth,
    window.innerHeight,
  ];
  // Focus click target
  event.target?.focus();
  document.addEventListener('mousemove', resizeMoveHandler);
  document.addEventListener('mouseup', resizeEndHandler);
  resizeMoveHandler(event);
};

const resizeEndHandler = event => {
  logger.log('resize end', size);
  resizeMoveHandler(event);
  document.removeEventListener('mousemove', resizeMoveHandler);
  document.removeEventListener('mouseup', resizeEndHandler);
  resizing = false;
  storeWindowGeometry();
};

const resizeMoveHandler = event => {
  if (!resizing) {
    return;
  }
  event.preventDefault();
  size = vecAdd(initialSize, vecMultiply(resizeMatrix, vecAdd(
    [event.screenX, event.screenY],
    vecInverse([window.screenLeft, window.screenTop]),
    dragPointOffset,
    [1, 1])));
  // Sane window size values
  size[0] = Math.max(size[0], 150);
  size[1] = Math.max(size[1], 50);
  setWindowSize(size);
};

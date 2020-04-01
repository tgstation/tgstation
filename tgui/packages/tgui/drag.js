import { vecAdd, vecInverse, vecMultiply } from 'common/vector';
import { winget, winset } from './byond';
import { createLogger } from './logging';

const logger = createLogger('drag');

let ref;
let dragging = false;
let resizing = false;
let screenOffset = [0, 0];
let dragPointOffset;
let resizeMatrix;
let initialSize;
let size;

const getWindowPosition = ref => {
  return winget(ref, 'pos').then(pos => [pos.x, pos.y]);
};

const setWindowPosition = (ref, vec) => {
  return winset(ref, 'pos', vec[0] + ',' + vec[1]);
};

const setWindowSize = (ref, vec) => {
  return winset(ref, 'size', vec[0] + ',' + vec[1]);
};

export const setupDrag = async state => {
  logger.log('setting up');
  ref = state.config.window;
  // Calculate offset caused by windows taskbar
  const realPosition = await getWindowPosition(ref);
  screenOffset = [
    realPosition[0] - window.screenLeft,
    realPosition[1] - window.screenTop,
  ];
  // Constraint window position
  const [relocated, safePosition] = constraintPosition(realPosition);
  if (relocated) {
    setWindowPosition(ref, safePosition);
  }
  logger.debug('current state', { ref, screenOffset });
};

/**
 * Constraints window position to safe screen area, accounting for safe
 * margins which could be a system taskbar.
 */
const constraintPosition = position => {
  let x = position[0];
  let y = position[1];
  let relocated = false;
  // Left
  if (x < 0) {
    x = 0;
    relocated = true;
  }
  // Right
  else if (x + window.innerWidth > window.screen.availWidth) {
    x = window.screen.availWidth - window.innerWidth;
    relocated = true;
  }
  // Top
  if (y < 0) {
    y = 0;
    relocated = true;
  }
  // Bottom
  else if (y + window.innerHeight > window.screen.availHeight) {
    y = window.screen.availHeight - window.innerHeight;
    relocated = true;
  }
  return [relocated, [x, y]];
};

export const dragStartHandler = event => {
  logger.log('drag start');
  dragging = true;
  dragPointOffset = [
    window.screenLeft - event.screenX,
    window.screenTop - event.screenY,
  ];
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
};

const dragMoveHandler = event => {
  if (!dragging) {
    return;
  }
  event.preventDefault();
  setWindowPosition(ref, vecAdd(
    [event.screenX, event.screenY],
    screenOffset,
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
  size[0] = Math.max(size[0], 250);
  size[1] = Math.max(size[1], 120);
  setWindowSize(ref, size);
};

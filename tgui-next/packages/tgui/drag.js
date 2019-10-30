import { winset, winget } from './byond';
import { createLogger } from './logging';

const logger = createLogger('drag');

const dragState = {
  dragging: false,
  resizing: false,
  windowRef: undefined,
  screenOffset: { x: 0, y: 0 },
  dragPointOffset: {},
  resizeMatrix: {},
  initialWindowSize: {},
};

export const setupDrag = async state => {
  logger.log('setting up');
  dragState.windowRef = state.config.window;
  // Remove window borders
  // NOTE: We are currently doing it in the open() tgui module proc, and
  // this bit of code is left here just in case everything goes to shit.
  // if (state.config.fancy) {
  //   winset(state.config.window, 'titlebar', false);
  //   winset(state.config.window, 'can-resize', false);
  // }
  // Calculate offset caused by windows taskbar
  const realPosition = await winget(dragState.windowRef, 'pos');
  dragState.screenOffset = {
    x: realPosition.x - window.screenX,
    y: realPosition.y - window.screenY,
  };
  // Constraint window position
  const [relocated, safePosition] = constraintPosition(realPosition);
  if (relocated) {
    winset(dragState.windowRef, 'pos',
      safePosition.x + ',' + safePosition.y);
  }
  logger.debug('current dragState', dragState);
};

/**
 * Constraints window position to safe screen area, accounting for safe
 * margins which could be a system taskbar.
 */
const constraintPosition = position => {
  let { x, y } = position;
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
  return [relocated, { x, y }];
};

export const dragStartHandler = event => {
  logger.log('drag start');
  dragState.dragging = true;
  dragState.dragPointOffset = {
    x: window.screenX - event.screenX,
    y: window.screenY - event.screenY,
  };
  document.addEventListener('mousemove', dragMoveHandler);
  document.addEventListener('mouseup', dragEndHandler);
  dragHandler(event);
};

export const dragMoveHandler = event => {
  dragHandler(event);
};

export const dragEndHandler = event => {
  logger.log('drag end');
  dragHandler(event);
  document.removeEventListener('mousemove', dragMoveHandler);
  document.removeEventListener('mouseup', dragEndHandler);
  dragState.dragging = false;
};

const dragHandler = event => {
  if (!dragState.dragging) {
    return;
  }
  event.preventDefault();
  let x = event.screenX
    + dragState.screenOffset.x
    + dragState.dragPointOffset.x;
  let y = event.screenY
    + dragState.screenOffset.y
    + dragState.dragPointOffset.y;
  winset(dragState.windowRef, 'pos', x + ',' + y);
};

export const resizeStartHandler = (x, y) => event => {
  logger.log('resize start', [x, y]);
  dragState.resizing = true;
  dragState.resizeMatrix = { x, y };
  dragState.dragPointOffset = {
    x: window.screenX - event.screenX,
    y: window.screenY - event.screenY,
  };
  dragState.initialWindowSize = {
    x: window.innerWidth,
    y: window.innerHeight,
  };
  document.addEventListener('mousemove', resizeMoveHandler);
  document.addEventListener('mouseup', resizeEndHandler);
  resizeHandler(event);
};

export const resizeMoveHandler = event => {
  resizeHandler(event);
};

export const resizeEndHandler = event => {
  logger.log('resize end');
  resizeHandler(event);
  document.removeEventListener('mousemove', resizeMoveHandler);
  document.removeEventListener('mouseup', resizeEndHandler);
  dragState.resizing = false;
};

const resizeHandler = event => {
  if (!dragState.resizing) {
    return;
  }
  event.preventDefault();
  let x = dragState.initialWindowSize.x
    + (event.screenX
      - window.screenX
      + dragState.dragPointOffset.x
      + 1)
    * dragState.resizeMatrix.x;
  let y = dragState.initialWindowSize.y
    + (event.screenY
      - window.screenY
      + dragState.dragPointOffset.y
      + 1)
    * dragState.resizeMatrix.y;
  winset(dragState.windowRef, 'size',
    // Sane window size values
    Math.max(x, 250) + ',' + Math.max(y, 120));
};

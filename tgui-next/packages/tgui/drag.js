import { winset, winget } from 'byond';
import { createLogger } from './logging';

const logger = createLogger('drag');

const dragState = {
  dragging: false,
  lastPosition: {},
  windowRef: undefined,
  screenOffset: { x: 0, y: 0 },
  dragPointOffset: {},
};

export const setupDrag = async state => {
  logger.log('setting up');
  dragState.windowRef = state.config.window;
  // Remove window borders
  if (state.config.fancy) {
    winset(state.config.window, 'titlebar', false);
    winset(state.config.window, 'can-resize', false);
  }
  // Calculate offset caused by windows taskbar
  const realPosition = await winget(dragState.windowRef, 'pos');
  dragState.screenOffset = {
    x: realPosition.x - window.screenX,
    y: realPosition.y - window.screenY,
  };
  logger.log('current dragState', dragState);
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
  // logger.log({ x, y });
  winset(dragState.windowRef, 'pos', [x, y].join(','));
};

import { WINDOW_SIZES } from './constants';

/**
 * Window functions
 */
/**
 * Once byond signals this via keystroke, it
 * ensures window size, visibility, and focus.
 */
export const windowOpen = (channel: string) => {
  setOpen();
  Byond.sendMessage('open', { channel });
};

/**
 * Resets the state of the window and hides it from user view.
 * Sending "close" logs it server side.
 */
export const windowClose = () => {
  setClosed();
  Byond.sendMessage('close');
};

/** Some QoL to hide the window on load. Doesn't log this event */
export const windowLoad = () => {
  Byond.winset('tgui_say', {
    pos: '848,500',
  });
  setClosed();
};

/**
 * Modifies the window size.
 *
 * Parameters:
 *  size - The size of the window in pixels. Optional.
 */
export const windowSet = (size: number = WINDOW_SIZES.small) => {
  Byond.winset('tgui_say', { size: `${WINDOW_SIZES.width}x${size}` });
  Byond.winset('tgui_say.browser', { size: `${WINDOW_SIZES.width}x${size}` });
};

/** Private functions */
/** Sets the skin props as opened. Focus might be a placebo here. */
const setOpen = () => {
  Byond.winset('tgui_say', {
    'is-visible': true,
    size: `${WINDOW_SIZES.width}x${WINDOW_SIZES.small}`,
  });
  Byond.winset('tgui_say.browser', {
    'is-visible': true,
    size: `${WINDOW_SIZES.width}x${WINDOW_SIZES.small}`,
  });
};

/** Sets the skin props as closed.  */
const setClosed = () => {
  Byond.winset('tgui_say', {
    'is-visible': false,
    size: `${WINDOW_SIZES.width}x${WINDOW_SIZES.small}`,
  });
  Byond.winset('map', {
    focus: true,
  });
};

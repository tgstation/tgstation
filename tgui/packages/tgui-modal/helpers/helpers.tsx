import { CHANNELS, SIZE } from '../constants/constants';
import { KEY_0, KEY_Z } from 'common/keycodes';
import { classes } from 'common/react';

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
  Byond.winset('tgui_modal', {
    pos: '694,602',
  });
  setClosed();
};

/**
 * Modifies the window size.
 *
 * Parameters:
 *  size - The size of the window in pixels. Optional.
 */
export const windowSet = (size: number = SIZE.small) => {
  Byond.winset('tgui_modal', { size: `${SIZE.width}x${size}` });
  Byond.winset('tgui_modal.browser', { size: `${SIZE.width}x${size}` });
};

/** Private functions */
/** Sets the skin props as opened. Focus might be a placebo here. */
const setOpen = () => {
  Byond.winset('tgui_modal', {
    'is-visible': true,
    size: `${SIZE.width}x${SIZE.small}`,
  });
  Byond.winset('tgui_modal.browser', {
    'is-visible': true,
    size: `${SIZE.width}x${SIZE.small}`,
  });
};

/** Sets the skin props as closed.  */
const setClosed = () => {
  Byond.winset('tgui_modal', {
    'is-visible': false,
    size: `${SIZE.width}x${SIZE.small}`,
  });
  Byond.winset('map', {
    focus: true,
  });
};

/**
 * Chat history functions
 */
/** Stores a list of chat messages entered as values */
let savedMessages: string[] = [];

/** Returns the chat history at specified index */
export const getHistoryAt = (index: number): string =>
  savedMessages[savedMessages.length - index];
/**
 * The length of chat history.
 * I am absolutely being excessive, but whatever
 */
export const getHistoryLength = (): number => savedMessages.length;
/**
 * Stores entries in the chat history.
 * Deletes old entries if the list is too long.
 */
export const storeChat = (message: string): void => {
  if (savedMessages.length === 5) {
    savedMessages.shift();
  }
  savedMessages.push(message);
};

/** Miscellaneous */
/** Returns modular css classes */
export const getCss = (
  element: string,
  channel?: number,
  size?: number
): string =>
  classes([
    element,
    valueExists(channel) && `${element}-${CHANNELS[channel!]?.toLowerCase()}`,
    valueExists(size) && `${element}-${size}`,
  ]);

/** Checks keycodes for alpha/numeric characters */
export const isAlphanumeric = (keyCode: number): boolean =>
  keyCode >= KEY_0 && keyCode <= KEY_Z;

/** Checks if a parameter is null or undefined. Returns bool */
export const valueExists = (param: any): boolean =>
  param !== null && param !== undefined;

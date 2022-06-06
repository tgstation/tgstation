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
export const windowOpen = (channel) => {
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
export const windowSet = (size = SIZE.small) => {
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
let savedMessages = [];

/** Returns the chat history at specified index */
export const getHistoryAt = (index) =>
  savedMessages[savedMessages.length - index];
/**
 * The length of chat history.
 * I am absolutely being excessive, but whatever
 */
export const getHistoryLength = () => savedMessages.length;
/**
 * Stores entries in the chat history.
 * Deletes old entries if the list is too long.
 */
export const storeChat = (message) => {
  if (savedMessages.length === 5) {
    savedMessages.shift();
  }
  savedMessages.push(message);
};

/** Miscellaneous */
/** Returns modular css classes */
export const getCss = (element, channel, size) =>
  classes([
    element,
    channel >= 0 && `${element}-${CHANNELS[channel]?.toLowerCase()}`,
    `${element}-${size}`,
  ]);

/** Checks keycodes for alpha/numeric characters */
export const isAlphanumeric = (keyCode) => keyCode >= KEY_0 && keyCode <= KEY_Z;

/**
 * Wraps a byond message in a cooldown.
 *
 * Parameters:
 *  message - The message to send.
 *  timeout - The cooldown in seconds.
 */
export class CooldownWrapper {
  constructor(message, timeout) {
    this.message = message;
    this.onCooldown = false;
    this.timeout = timeout;
  }
  setTimer = () => {
    this.onCooldown = true;
    setTimeout(() => {
      this.onCooldown = false;
    }, this.timeout);
  };
  sendMessage = () => {
    if (!this.onCooldown) {
      Byond.sendMessage(this.message);
      this.setTimer();
    }
  };
}

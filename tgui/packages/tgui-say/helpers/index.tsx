import { CHANNELS, RADIO_PREFIXES, WINDOW_SIZES } from '../constants';
import { KEY_0, KEY_Z } from 'common/keycodes';
import { classes } from 'common/react';
import { debounce, throttle } from 'common/timer';

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

/**
 * Returns modular css classes.
 *
 * Parameters:
 * element - required string. The element selector.
 * theme - optional string. The theme to apply.
 * options - optional string | number. Adds another css selector.
 */
export const getCss = (
  element: string,
  theme?: string,
  options?: string | number
): string =>
  classes([
    element,
    valueExists(theme) && `${element}-${theme}`,
    valueExists(options) && `${element}-${options}`,
  ]);

/**
 * Returns a string that represents the css selector to use.
 * Light mode takes precedence over radioPrefixes,
 * radioPrefixes takes precedence over channel.
 *
 * Parameters:
 * lightMode - boolean. If true, returns the light mode selector.
 * radioPrefix - string. If not empty, returns the radio prefix selector.
 * channel - number. The channel to use.
 */
export const getTheme = (
  lightMode: boolean,
  radioPrefix: string,
  channel: number
): string => {
  return (
    (lightMode && 'lightMode')
    || RADIO_PREFIXES[radioPrefix]?.id
    || CHANNELS[channel]?.toLowerCase()
  );
};

/** Checks keycodes for alpha/numeric characters */
export const isAlphanumeric = (keyCode: number): boolean =>
  keyCode >= KEY_0 && keyCode <= KEY_Z;

/** Timers: Prevents overloading the server, throttles messages */
export const timers = {
  channelDebounce: debounce((mode) => Byond.sendMessage('thinking', mode), 400),
  forceDebounce: debounce(
    (entry) => Byond.sendMessage('force', entry),
    1000,
    true
  ),
  typingThrottle: throttle(() => Byond.sendMessage('typing'), 4000),
};

/** Checks if a parameter is null or undefined. Returns bool */
export const valueExists = (param: any): boolean =>
  param !== null && param !== undefined;

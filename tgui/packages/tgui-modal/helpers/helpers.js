import { CHANNELS, SIZE } from '../constants/constants';
import { KEY_0, KEY_Z } from 'common/keycodes';
import { classes } from 'common/react';

/**
 * Once byond signals this via keystroke, it
 * ensures window size, visibility, and focus.
 */
export const windowOpen = () => {
  Byond.winset('tgui_modal', {
    'is-visible': true,
    focus: true,
    size: `333x${SIZE.small}`,
  });
  Byond.sendMessage('open');
};
/** Resets the state of the window and hides it from user view */
export const windowClose = () => {
  Byond.winset('tgui_modal', {
    'is-visible': false,
    size: `333x${SIZE.small}`,
  });
  Byond.winset('map', {
    focus: true,
  });
  Byond.sendMessage('close');
};
/**
 * Modifies the window size.
 *
 * Parameters:
 * size: The size of the window in pixels. Optional.
 */
export const windowSet = (size = SIZE.small) => {
  Byond.winset('tgui_modal', { size: `333x${size}` });
  Byond.winset('tgui_modal.browser', { size: `333x${size}` });
};
/** Returns modular css classes */
export const getCss = (element, channel, size) =>
  classes([element, `${element}-${CHANNELS[channel]}`, `${element}-${size}`]);
/** Checks keycodes for alpha/numeric characters */
export const isAlphanumeric = (keyCode) => keyCode >= KEY_0 && keyCode <= KEY_Z;

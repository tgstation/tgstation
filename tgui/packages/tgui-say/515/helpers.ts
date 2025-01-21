import { Channel } from '../ChannelIterator';
import { WINDOW_SIZES } from './constants';

/**
 * Once byond signals this via keystroke, it
 * ensures window size, visibility, and focus.
 */
export const windowOpen = (channel: Channel) => {
  setWindowVisibility(true);
  Byond.sendMessage('open', { channel });
};

/**
 * Resets the state of the window and hides it from user view.
 * Sending "close" logs it server side.
 */
export const windowClose = () => {
  setWindowVisibility(false);
  Byond.winset('map', {
    focus: true,
  });
  Byond.sendMessage('close');
};

/**
 * Modifies the window size.
 */
export const windowSet = (size = WINDOW_SIZES.small) => {
  let sizeStr = `${WINDOW_SIZES.width}x${size}`;

  Byond.winset('tgui_say.browser', {
    size: sizeStr,
  });

  Byond.winset('tgui_say', {
    size: sizeStr,
  });
};

/** Helper function to set window size and visibility */
const setWindowVisibility = (visible: boolean) => {
  Byond.winset('tgui_say', {
    'is-visible': visible,
    size: `${WINDOW_SIZES.width}x${WINDOW_SIZES.small}`,
  });
};

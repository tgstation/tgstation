import { Channel } from './ChannelIterator';
import { WINDOW_SIZES } from './constants';

/**
 * Once byond signals this via keystroke, it
 * ensures window size, visibility, and focus.
 */
export const windowOpen = (channel: Channel) => {
  setWindowSizeAndVisibility(true, WINDOW_SIZES.small);
  Byond.sendMessage('open', { channel });
};

/**
 * Resets the state of the window and hides it from user view.
 * Sending "close" logs it server side.
 */
export const windowClose = () => {
  setWindowSizeAndVisibility(false, WINDOW_SIZES.small);
  Byond.winset('map', {
    focus: true,
  });
  Byond.sendMessage('close');
};

/** Some QoL to hide the window on load. Doesn't log this event */
export const windowLoad = () => {
  Byond.winset('tgui_say', {
    pos: '848,500',
  });
  setWindowSizeAndVisibility(false, WINDOW_SIZES.small);
  Byond.winset('map', {
    focus: true,
  });
};

/**
 * Modifies the window size.
 */
export const windowSet = (size = WINDOW_SIZES.small) => {
  setWindowSizeAndVisibility(true, size);
};

/** Helper function to set window size and visibility */
const setWindowSizeAndVisibility = (isVisible: boolean, size: number) => {
  const sizeStr = `${WINDOW_SIZES.width}x${size}`;

  Byond.winset('tgui_say', {
    'is-visible': isVisible,
    size: sizeStr,
  });

  Byond.winset('tgui_say.browser', {
    'is-visible': isVisible,
    size: sizeStr,
  });
};

import { Channel } from './ChannelIterator';
import { RADIO_PREFIXES, WindowSize } from './constants';

/**
 * Once byond signals this via keystroke, it
 * ensures window size, visibility, and focus.
 */
export function windowOpen(channel: Channel, scale: boolean): void {
  setWindowVisibility(true, scale);
  Byond.sendMessage('open', { channel });
}

/**
 * Resets the state of the window and hides it from user view.
 * Sending "close" logs it server side.
 */
export function windowClose(scale: boolean): void {
  setWindowVisibility(false, scale);
  Byond.winset('map', {
    focus: true,
  });
  Byond.sendMessage('close');
}

/**
 * Modifies the window size.
 */
export function windowSet(size = WindowSize.Small, scale: boolean): void {
  const pixelRatio = scale ? window.devicePixelRatio : 1;

  const sizeStr = `${WindowSize.Width * pixelRatio}x${size * pixelRatio}`;

  Byond.winset(null, {
    'tgui_say.size': sizeStr,
    'tgui_say.browser.size': sizeStr,
  });
}

/** Helper function to set window size and visibility */
function setWindowVisibility(visible: boolean, scale: boolean): void {
  const pixelRatio = scale ? window.devicePixelRatio : 1;

  const sizeStr = `${WindowSize.Width * pixelRatio}x${WindowSize.Small * pixelRatio}`;

  Byond.winset(null, {
    'tgui_say.is-visible': visible,
    'tgui_say.size': sizeStr,
    'tgui_say.browser.size': sizeStr,
  });
}

const CHANNEL_REGEX = /^[:.]\w\s/;

/** Tests for a channel prefix, returning it or none */
export function getPrefix(
  value: string,
): keyof typeof RADIO_PREFIXES | undefined {
  if (!value || value.length < 3 || !CHANNEL_REGEX.test(value)) {
    return;
  }

  let adjusted = value
    .slice(0, 3)
    ?.toLowerCase()
    ?.replace('.', ':') as keyof typeof RADIO_PREFIXES;

  if (!RADIO_PREFIXES[adjusted]) {
    return;
  }

  return adjusted;
}

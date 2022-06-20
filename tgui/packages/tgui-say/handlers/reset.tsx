import { CHANNELS, WINDOW_SIZES } from '../constants';
import { valueExists } from '../helpers';
import { Modal } from '../types';

/**
 * Resets window to default parameters.
 *
 * Parameters:
 * channel - Optional. Sets the channel and thus the color scheme.
 */
export const handleReset = function (this: Modal, channel?: number) {
  this.fields.historyCounter = 0;
  this.fields.radioPrefix = '';
  this.fields.value = '';
  this.setState({
    buttonContent: valueExists(channel) ? CHANNELS[channel!] : '',
    channel: valueExists(channel) ? channel! : -1,
    edited: true,
    size: WINDOW_SIZES.small,
  });
};

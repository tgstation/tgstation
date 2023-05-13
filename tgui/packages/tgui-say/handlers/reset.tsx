import { WINDOW_SIZES } from '../constants';

import { Modal } from '../types';

/**
 * Resets window to default parameters.
 *
 * Parameters:
 * channel - Optional. Sets the channel and thus the color scheme.
 */
export const handleReset: Modal['handlers']['reset'] = function (this: Modal) {
  const { channelIterator } = this.fields;

  this.fields.currentPrefix = null;
  this.fields.currentValue = '';

  this.setState({
    buttonContent: channelIterator.current(),
    edited: true,
    size: WINDOW_SIZES.small,
  });
};

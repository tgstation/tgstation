import { Handlers } from '.';
import { WINDOW_SIZES } from '../constants';
import { TguiSay } from '../TguiSay';

/**
 * Resets window to default parameters.
 *
 * Parameters:
 * channel - Optional. Sets the channel and thus the color scheme.
 */
export const handleReset: Handlers['reset'] = function (this: TguiSay) {
  const { channelIterator, chatHistory } = this.fields;

  this.fields.currentPrefix = null;
  channelIterator.reset();
  chatHistory.reset();

  this.setState({
    buttonContent: channelIterator.current(),
    size: WINDOW_SIZES.small,
    value: '',
  });
};

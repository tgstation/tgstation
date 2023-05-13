import { LINE_LENGTHS, WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { Modal } from '../types';

/**  Adjusts window sized based on event.target.value */
export const handleSetSize: Modal['handlers']['setSize'] = function (
  this: Modal,
  value
) {
  let newSize: WINDOW_SIZES;

  if (value > LINE_LENGTHS.medium) {
    newSize = WINDOW_SIZES.large;
  } else if (value <= LINE_LENGTHS.medium && value > LINE_LENGTHS.small) {
    newSize = WINDOW_SIZES.medium;
  } else {
    newSize = WINDOW_SIZES.small;
  }

  if (this.state.size !== newSize) {
    this.setState({ size: newSize });
    windowSet(newSize);
  }
};

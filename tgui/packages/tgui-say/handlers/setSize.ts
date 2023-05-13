import { Handlers } from '.';
import { LINE_LENGTHS, WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { TguiSay } from '../TguiSay';

/**  Adjusts window sized based on event.target.value */
export const handleSetSize: Handlers['setSize'] = function (
  this: TguiSay,
  value = 0
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

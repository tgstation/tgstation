import { WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { TguiModal } from '../types';

/**  Adjusts window sized based on event.target.value */
export const handleSetSize = function (this: TguiModal, value: number) {
  const { size } = this.state;
  if (value > 51 && size !== WINDOW_SIZES.large) {
    this.setState({ size: WINDOW_SIZES.large });
    windowSet(WINDOW_SIZES.large);
  } else if (value <= 51 && value > 22 && size !== WINDOW_SIZES.medium) {
    this.setState({ size: WINDOW_SIZES.medium });
    windowSet(WINDOW_SIZES.medium);
  } else if (value <= 22 && size !== WINDOW_SIZES.small) {
    this.setState({ size: WINDOW_SIZES.small });
    windowSet(WINDOW_SIZES.small);
  }
};

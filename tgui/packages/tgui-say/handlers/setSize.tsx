import { WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { Modal } from '../types';

/**  Adjusts window sized based on event.target.value */
export const handleSetSize = function (this: Modal, value: number) {
  const { size } = this.state;
  if (value > 35 && size !== WINDOW_SIZES.large) {
    this.setState({ size: WINDOW_SIZES.large });
    windowSet(WINDOW_SIZES.large);
  } else if (value <= 35 && value > 20 && size !== WINDOW_SIZES.medium) {
    this.setState({ size: WINDOW_SIZES.medium });
    windowSet(WINDOW_SIZES.medium);
  } else if (value <= 20 && size !== WINDOW_SIZES.small) {
    this.setState({ size: WINDOW_SIZES.small });
    windowSet(WINDOW_SIZES.small);
  }
};

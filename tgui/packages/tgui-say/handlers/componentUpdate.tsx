import { Modal } from '../types';

/** After updating the input value, sets back to false */
export const handleComponentUpdate: Modal['handlers']['componentUpdate'] =
  function (this: Modal) {
    this.setState({ edited: false });
  };

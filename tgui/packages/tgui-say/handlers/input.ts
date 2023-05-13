import { Handlers } from '.';
import { TguiSay } from '../TguiSay';

/**
 * Grabs input and sets size, force values etc.
 * Input value only triggers a rerender on setEdited.
 */
export const handleInput: Handlers['input'] = function (
  this: TguiSay,
  _, // event
  value
) {
  const { radioPrefix, setSize } = this.handlers;
  const { innerRef } = this.fields;

  const currentValue = innerRef.current?.value;

  radioPrefix();
  setSize(currentValue?.length || 0);
};

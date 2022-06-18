import { dragStartHandler } from 'tgui/drag';
import { DragzoneProps } from '../types';

/** Creates a draggable edge. Props Req: Location */
export const Dragzone = (props: Partial<DragzoneProps>) => {
  const { theme } = props;
  if (!theme) return null;
  const direction
    = (props.top && 'top')
    || (props.right && 'right')
    || (props.bottom && 'bottom')
    || (props.left && 'left');

  return (
    <div
      className={`dragzone-${direction}-${theme}`}
      onmousedown={dragStartHandler}
    />
  );
};

import { dragStartHandler } from 'tgui/drag';

interface Props {
  horizontal: boolean;
  vertical: boolean;
}

/** Creates a draggable edge. Props Req: horizontal or vertical. */
export const Dragzone = (props: Partial<Props>) => {
  const direction
    = (props.horizontal && 'horizontal') || (props.vertical && 'vertical');

  return (
    <div className={`dragzone-${direction}`} onmousedown={dragStartHandler} />
  );
};

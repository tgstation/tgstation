import { dragStartHandler } from 'tgui/drag';

export const Dragzone = (props) => {
  const direction =
    (props.horizontal && 'horizontal') || (props.vertical && 'vertical');
  return (
    <div className={`dragzone-${direction}`} onmousedown={dragStartHandler} />
  );
};

import { dragStartHandler } from 'tgui/drag';

export const Dragzone = (props) => {
  const direction
    = (props.top && 'top')
    || (props.bottom && 'bottom')
    || (props.vertical && 'vertical');
  return (
    <div className={`dragzone-${direction}`} onmousedown={dragStartHandler} />
  );
};

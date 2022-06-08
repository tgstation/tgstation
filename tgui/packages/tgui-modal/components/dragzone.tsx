import { dragStartHandler } from 'tgui/drag';

interface Props {
  horizontal: boolean,
  vertical: boolean,
}

export const Dragzone = (props: Partial<Props>) => {
  const direction
    = (props.horizontal && 'horizontal')
    || (props.vertical && 'vertical');
  return (
    <div className={`dragzone-${direction}`} onmousedown={dragStartHandler} />
  );
};

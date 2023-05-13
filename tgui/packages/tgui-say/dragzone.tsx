import { dragStartHandler } from 'tgui/drag';

type Props = {
  theme: string;
  top: boolean;
  right: boolean;
  bottom: boolean;
  left: boolean;
};

/** Creates a draggable edge. Props Req: Location */
export const Dragzone = (props: Partial<Props>) => {
  const { theme } = props;
  if (!theme) return null;
  const direction =
    (props.top && 'top') ||
    (props.right && 'right') ||
    (props.bottom && 'bottom') ||
    (props.left && 'left');

  return (
    <div
      className={`dragzone-${direction}-${theme}`}
      onmousedown={dragStartHandler}
    />
  );
};

import { classes } from 'tgui-core/react';

const Z_INDEX_STAMP = 1;
const Z_INDEX_STAMP_PREVIEW = 2;

// Creates a full stamp div to render the given stamp to the preview.
export function Stamp(props) {
  const { activeStamp, sprite, x, y, rotation, opacity, yOffset = 0 } = props;
  const stamp_transform = {
    left: `${x}px`,
    top: `${y + yOffset}px`,
    transform: `rotate(${rotation}deg)`,
    opacity: opacity || 1.0,
    zIndex: activeStamp ? Z_INDEX_STAMP_PREVIEW : Z_INDEX_STAMP,
  };

  return (
    <div
      id="stamp"
      className={classes(['Paper__Stamp', sprite])}
      style={stamp_transform}
    />
  );
}

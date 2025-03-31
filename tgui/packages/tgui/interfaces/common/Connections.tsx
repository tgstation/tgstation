import { classes } from 'tgui-core/react';

import { CSS_COLORS } from '../../constants';

const SVG_CURVE_INTENSITY = 64;

enum ConnectionStyle {
  CURVE = 'curve',
  SUBWAY = 'subway',
}

export type Position = {
  x: number;
  y: number;
};

export type Connection = {
  // X, Y starting point
  from: Position;
  // X, Y ending point
  to: Position;
  // Color of the line, defaults to blue
  color?: string;
  // Type of line - Curvy or Straight / angled, defaults to curvy
  style?: ConnectionStyle;
  // Optional: the ref of what element this connection is sourced
  ref?: string;
};

export const Connections = (props: {
  connections: Connection[];
  zLayer?: number;
  lineWidth?: number;
}) => {
  const { connections, zLayer = -1, lineWidth = '2px' } = props;

  const isColorClass = (str) => {
    if (typeof str === 'string') {
      return CSS_COLORS.includes(str as any);
    }
  };

  return (
    <svg
      width="100%"
      height="100%"
      style={{
        position: 'absolute',
        pointerEvents: 'none',
        zIndex: zLayer,
        overflow: 'visible',
      }}
    >
      {connections.map((val, index) => {
        const from = val.from;
        const to = val.to;
        if (!to || !from) {
          return;
        }

        val.color = val.color || 'blue';
        val.style = val.style || ConnectionStyle.CURVE;

        // Starting point
        let path = `M ${from.x} ${from.y}`;

        switch (val.style) {
          case ConnectionStyle.CURVE: {
            path += `C ${from.x + SVG_CURVE_INTENSITY}, ${from.y},`;
            path += `${to.x - SVG_CURVE_INTENSITY}, ${to.y},`;
            path += `${to.x}, ${to.y}`;
            break;
          }
          case ConnectionStyle.SUBWAY: {
            const yDiff = Math.abs(from.y - (to.y - 16));
            path += `L ${to.x - yDiff} ${from.y}`;
            path += `L ${to.x - 16} ${to.y}`;
            path += `L ${to.x} ${to.y}`;
            break;
          }
        }

        return (
          <path
            className={classes([
              isColorClass(val.color) && `color-stroke-${val.color}`,
            ])}
            key={index}
            d={path}
            fill="transparent"
            stroke-width={lineWidth}
          />
        );
      })}
    </svg>
  );
};

import { CSS_COLORS } from '../../constants';
import { SVG_CURVE_INTENSITY } from './constants';
import { classes } from '../../../common/react';

export const Connections = (props, context) => {
  const { connections } = props;

  const isColorClass = (str) => {
    if (typeof str === 'string') {
      return CSS_COLORS.includes(str);
    }
  };

  return (
    <svg
      width="100%"
      height="100%"
      style={{
        'position': 'absolute',
        'pointer-events': 'none',
        'z-index': -1,
      }}>
      {connections.map((val, index) => {
        const from = val.from;
        const to = val.to;
        if (!to || !from) {
          return;
        }
        // Starting point
        let path = `M ${from.x} ${from.y}`;
        // DEFAULT STYLE
        path += `C ${from.x + SVG_CURVE_INTENSITY}, ${from.y},`;
        path += `${to.x - SVG_CURVE_INTENSITY}, ${to.y},`;
        path += `${to.x}, ${to.y}`;

        // SUBWAY STYLE
        // const yDiff = Math.abs(from.y - (to.y - 16));
        // path += `L ${to.x - yDiff} ${from.y}`;
        // path += `L ${to.x - 16} ${to.y}`;
        // path += `L ${to.x} ${to.y}`;

        val.color = val.color || 'blue';
        return (
          <path
            className={classes([
              isColorClass(val.color) && `color-stroke-${val.color}`,
            ])}
            key={index}
            d={path}
            fill="transparent"
            stroke-width="2px"
          />
        );
      })}
    </svg>
  );
};

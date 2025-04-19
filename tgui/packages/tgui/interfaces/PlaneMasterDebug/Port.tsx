import { Box } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { BlendColors, Filter, Relay } from './types';

export type PortProps = {
  connection: Filter | Relay;
  target_ref: (element: HTMLElement) => void;
};

export function Port(props: PortProps) {
  const { connection, target_ref } = props;
  return (
    <Box className={classes(['ObjectComponent__Port'])} textAlign="center">
      <svg
        style={{
          width: '100%',
          height: '100%',
        }}
        viewBox="0, 0, 100, 100"
      >
        <circle
          stroke={connection.node_color}
          strokeDasharray={`${100 * Math.PI}`}
          strokeDashoffset={-100 * Math.PI}
          className={`color-stroke-${connection.node_color}`}
          strokeWidth="50px"
          cx="50"
          cy="50"
          r="50"
          fillOpacity="0"
          transform="rotate(90, 50, 50)"
        />
        <circle
          cx="50"
          cy="50"
          r="50"
          className={`color-fill-${connection.node_color}`}
        />
        <circle
          cx="50"
          cy="50"
          r="25"
          className={`color-fill-${BlendColors[connection.blend_mode || 'BLEND_DEFAULT'] || connection.node_color}`}
        />
      </svg>
      <span ref={target_ref} className="ObjectComponent__PortPos" />
    </Box>
  );
}

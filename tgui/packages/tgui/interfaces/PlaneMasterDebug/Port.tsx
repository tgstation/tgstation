import { Box, Button, Floating, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { BlendColors, type Filter, type Plane, type Relay } from './types';
import { usePlaneDebugContext } from './usePlaneDebug';

export type PortProps = {
  connection: Filter | Relay;
  source?: boolean;
  target_ref: (element: HTMLElement) => void;
};

export function Port(props: PortProps) {
  const { connection, source, target_ref } = props;
  const { act } = useBackend();
  const { setConnectionHighlight } = usePlaneDebugContext();
  const sourcePlane: Plane = (
    source ? connection.source : connection.target
  ) as Plane;
  const connectedPlane: Plane = (
    source ? connection.target : connection.source
  ) as Plane;
  return (
    <Floating
      content={
        <Stack fill vertical>
          <Stack.Item>Connected to {connectedPlane.name}</Stack.Item>
          {!!(connection.blend_mode !== undefined) && (
            <Stack.Item>Blend mode: {connection.blend_mode}</Stack.Item>
          )}
          {!!('type' in connection) && (
            <Stack.Item>Filter type: {connection.type}</Stack.Item>
          )}
          <Button
            color="bad"
            width="120px"
            onClick={() => {
              if ('type' in connection) {
                act('disconnect_filter', {
                  target: connection.target?.plane,
                  name: connection.name,
                });
              } else {
                act('disconnect_relay', {
                  source: connection.source?.plane,
                  target: connection.target?.plane,
                });
              }
            }}
          >
            Delete connection
          </Button>
        </Stack>
      }
      placement="bottom"
      contentClasses="Tooltip__Port"
    >
      <Box
        className={classes(['ObjectComponent__Port'])}
        textAlign="center"
        onMouseOver={() => {
          setConnectionHighlight({
            source: sourcePlane.plane,
            target: connectedPlane.plane,
          });
        }}
        onMouseLeave={() => {
          setConnectionHighlight(undefined);
        }}
      >
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
    </Floating>
  );
}

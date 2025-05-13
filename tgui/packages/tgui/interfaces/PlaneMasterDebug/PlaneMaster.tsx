import { Box, Button, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { getWindowPosition, setWindowPosition } from '../../drag';
import { Port } from './Port';
import { Filter, Plane, PlaneConnectorsMap, Relay } from './types';
import { usePlaneDebugContext } from './usePlaneDebug';

export type PlaneMasterProps = {
  plane: Plane;
  connectionData: PlaneConnectorsMap;
};

export function PlaneMaster(props: PlaneMasterProps) {
  const { plane, connectionData } = props;
  const {
    connectionHighlight,
    activePlane,
    setActivePlane,
    setConnectionOpen,
    planeOpen,
    setPlaneOpen,
  } = usePlaneDebugContext();

  const incoming_connections: (Filter | Relay)[] = (
    plane.incoming_filters as (Filter | Relay)[]
  )
    .concat(plane.incoming_relays)
    .filter((x: Filter | Relay) => {
      return x.source !== undefined;
    })
    .sort(
      (a: Filter | Relay, b: Filter | Relay) =>
        (a.source as Plane).plane - (b.source as Plane).plane,
    );

  const outgoing_connections: (Filter | Relay)[] = (
    plane.outgoing_filters as (Filter | Relay)[]
  )
    .concat(plane.outgoing_relays)
    .filter((x: Filter | Relay) => {
      return x.target !== undefined;
    })
    .sort(
      (a: Filter | Relay, b: Filter | Relay) =>
        (a.target as Plane).plane - (b.target as Plane).plane,
    );

  return (
    <Box
      position="absolute"
      left={`${plane.position.x}px`}
      top={`${plane.position.y}px`}
      minWidth="150px"
      style={
        connectionHighlight?.target === plane.plane ||
        activePlane === plane.plane
          ? {
              outline: '2px outset hsl(0, 0%, 85%)',
              borderTopLeftRadius: 'var(--border-radius-huge)',
              borderTopRightRadius: 'var(--border-radius-huge)',
            }
          : {}
      }
    >
      <Box
        backgroundColor={plane.force_hidden ? '#191919' : '#000000'}
        py={1}
        px={1}
        className="ObjectComponent__Titlebar"
        style={
          plane.force_hidden
            ? {
                borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
              }
            : {}
        }
      >
        <Stack>
          <Stack.Item grow>{plane.name}</Stack.Item>
          <Stack.Item>
            <Button
              icon="pager"
              compact
              tooltip="Inspect and edit this plane"
              onClick={() => {
                setActivePlane(plane.plane);
                if (planeOpen) {
                  return;
                }
                const windowPosition = getWindowPosition();
                windowPosition[0] -= 150;
                setWindowPosition(windowPosition);
                setPlaneOpen(true);
              }}
            />
          </Stack.Item>
        </Stack>
      </Box>

      <Box
        className={classes([
          plane.force_hidden
            ? 'ObjectComponent__Greyed_Content'
            : 'ObjectComponent__Content',
        ])}
        py={1}
        px={1}
      >
        <Stack>
          <Stack.Item>
            <Stack vertical>
              {incoming_connections.map((connection: Filter | Relay) => (
                <Stack.Item key={connection.our_ref}>
                  <Port
                    connection={connection}
                    target_ref={(element) => {
                      if (connectionData[connection.our_ref] === undefined) {
                        connectionData[connection.our_ref] = {};
                      }
                      connectionData[connection.our_ref].input = element;
                    }}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item grow />
          <Stack.Item>
            <Stack vertical>
              {outgoing_connections.map((connection: Filter | Relay) => (
                <Stack.Item key={connection.our_ref} align="flex-end">
                  <Port
                    connection={connection}
                    source
                    target_ref={(element) => {
                      if (connectionData[connection.our_ref] === undefined) {
                        connectionData[connection.our_ref] = {};
                      }
                      connectionData[connection.our_ref].output = element;
                    }}
                  />
                </Stack.Item>
              ))}
              <Stack.Item align="flex-end">
                <Button
                  icon="plus"
                  compact
                  onClick={() => {
                    setActivePlane(plane.plane);
                    setConnectionOpen(true);
                  }}
                  tooltip="Connect to another plane"
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Box>
    </Box>
  );
}

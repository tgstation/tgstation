import { useContext } from 'react';
import { Box, Button, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { PlaneDebugContext } from '.';
import { Port } from './Port';
import { Filter, Plane, PlaneConnectorsMap, Relay } from './types';

export type PlaneMasterProps = {
  plane: Plane;
  connectionData: PlaneConnectorsMap;
  act: Function;
};

export function PlaneMaster(props: PlaneMasterProps) {
  const { plane, connectionData, act } = props;
  const {
    connectionHighlight,
    activePlane,
    setActivePlane,
    setConnectionOpen,
  } = useContext(PlaneDebugContext);

  let incoming_connections: (Filter | Relay)[] = plane.incoming_filters
    .concat(plane.incoming_relays)
    .filter((x: Filter | Relay) => {
      return x.source !== undefined;
    })
    .sort(
      (a: Filter | Relay, b: Filter | Relay) =>
        (a.source as Plane).plane - (b.source as Plane).plane,
    );

  let outgoing_connections: (Filter | Relay)[] = plane.outgoing_filters
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
              onClick={() => setActivePlane(plane.plane)}
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
                    act={act}
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
                    act={act}
                  />
                </Stack.Item>
              ))}
              <Stack.Item align="flex-end">
                <Button
                  icon="plus"
                  compact
                  onClick={() => {
                    setConnectionOpen(true);
                    setActivePlane(plane.plane);
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

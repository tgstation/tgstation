import { Box, Button, Stack } from 'tgui-core/components';

import { Port } from './Port';
import { Filter, Plane, PlaneConnectorsMap, Relay } from './types';

export type PlaneMasterProps = {
  plane: Plane;
  connectionData: PlaneConnectorsMap;
  act: Function;
};

export function PlaneMaster(props: PlaneMasterProps) {
  const { plane, connectionData, act } = props;
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
              onClick={() => act('perform_action')}
            />
          </Stack.Item>
        </Stack>
      </Box>

      <Box
        className={
          plane.force_hidden
            ? 'ObjectComponent__Greyed_Content'
            : 'ObjectComponent__Content'
        }
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
                  onClick={() => act('')}
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

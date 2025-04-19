import { sortBy } from 'common/collections';
import { Box, Button, Stack } from 'tgui-core/components';

import { Port } from './Port';
import { Filter, Plane, PlaneConnectorsMap, Relay } from './types';

export type PlaneMasterProps = {
  x: number;
  y: number;
  plane: Plane;
  connectionData: PlaneConnectorsMap;
};

export function PlaneMaster(props: PlaneMasterProps) {
  const { x, y, plane, connectionData } = props;
  let incoming_connections: (Filter | Relay)[] = [
    ...sortBy(plane.incoming_relays, (relay: Relay) => relay.source?.plane),
    ...sortBy(plane.incoming_filters, (filter: Filter) => filter.source?.plane),
  ];
  let outgoing_connections: (Filter | Relay)[] = [
    ...sortBy(plane.outgoing_relays, (relay: Relay) => relay.target?.plane),
    ...sortBy(plane.outgoing_filters, (filter: Filter) => filter.target?.plane),
  ];

  return (
    <Box position="absolute" left={`${x}px`} top={`${y}px`} minWidth="150px">
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
        {plane.name}
        <Button
          ml={2}
          icon="pager"
          tooltip="Inspect and edit this plane"
          style={{ float: 'right' }}
        />
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
                  onClick={() => {}}
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

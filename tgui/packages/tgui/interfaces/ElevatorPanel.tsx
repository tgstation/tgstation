import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Dimmer, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type FloorData = {
  name: string;
  z_level: number;
};

type ElevatorPanelData = {
  panel_z: number;
  emergency_level: string;
  is_emergency: BooleanLike;
  doors_open: BooleanLike;
  lift_exists: BooleanLike;
  currently_moving: BooleanLike;
  current_floor: number;
  all_floor_data: FloorData[];
};

export const ElevatorPanel = (props, context) => {
  const { data, act } = useBackend<ElevatorPanelData>(context);

  const leftDestinations = data.all_floor_data.filter((e, index) => {
    return index % 2 === 0;
  });

  const rightDestinations = data.all_floor_data.filter((e, index) => {
    return index % 2 === 1;
  });

  return (
    <Window width={250} height={375}>
      <Window.Content>
        <Section>
          {!data.lift_exists && <NoLiftDimmer />}
          {!!data.currently_moving && <MovingDimmer />}
          <Stack vertical align="center" fill>
            <Stack.Item height="50px">
              <Box
                style={{
                  'font-family': 'Consolas',
                  'font-size': '50px',
                }}>
                {data.current_floor - 1}
              </Box>
            </Stack.Item>
            <Stack.Item height="200px">
              <Stack>
                {leftDestinations.map((floor, index) => (
                  <Stack.Item key={index} mb={1}>
                    <Button
                      disabled={floor.z_level === data.current_floor}
                      onClick={() => act('move_lift', { z: floor.z_level })}>
                      {floor.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
              <Stack>
                {rightDestinations.map((floor, index) => (
                  <Stack.Item key={index}>
                    <Button
                      disabled={floor.z_level === data.current_floor}
                      onClick={() => act('move_lift', { z: floor.z_level })}>
                      {floor.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Stack.Item height="50px">
              {data.doors_open ? (
                <Button
                  tooltip={
                    'Closes all elevator doors, except \
                    those on the level of the elevator.'
                  }
                  onClick={() => act('reset_doors')}>
                  Reset Doors
                </Button>
              ) : (
                <Button
                  disabled={!data.is_emergency}
                  color={'bad'}
                  tooltip={
                    data.is_emergency
                      ? 'In case of emergency, Opens all lift doors.'
                      : `The station is only at ${data.emergency_level} alert.`
                  }
                  onClick={() => act('emergency_door')}>
                  Emergency
                </Button>
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const NoLiftDimmer = () => {
  return (
    <Dimmer>
      <Stack vertical fill align="center">
        <Stack.Item>
          <Icon size={8} name="exclamation" />
        </Stack.Item>
        <Stack.Item fontSize="16px">No elevator connected.</Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const MovingDimmer = () => {
  return (
    <Dimmer>
      <Stack vertical fill align="center">
        <Stack.Item>
          <Icon size={8} name="spinner" spin />
        </Stack.Item>
        <Stack.Item fontSize="16px">Moving...</Stack.Item>
      </Stack>
    </Dimmer>
  );
};

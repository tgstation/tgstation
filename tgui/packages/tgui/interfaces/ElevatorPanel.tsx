import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Dimmer, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type FloorData = {
  name: string;
  z_level: number;
};

type ElevatorPanelData = {
  // What Z the panel itself is on
  panel_z: number;
  // What Z the lift is on
  current_floor: number;
  // Station emergency level - "Red", "Green", etc
  emergency_level: string;
  // State: Is the station in red or delta alert?
  is_emergency: BooleanLike;
  // State: Are the doors emergency opened?
  doors_open: BooleanLike;
  // State: Does the lift exist?
  lift_exists: BooleanLike;
  // State: Is the lift moving?
  currently_moving: BooleanLike;
  // A list of all floors we can move around to
  all_floor_data: FloorData[];
};

export const ElevatorPanel = (props, context) => {
  const { data, act } = useBackend<ElevatorPanelData>(context);

  return (
    <Window width={200} height={450} theme="retro">
      <Window.Content align="center">
        {!data.lift_exists && <NoLiftDimmer />}
        <Section height="18%">
          <Box
            style={{
              'font-family': 'Consolas',
              'font-size': '50px',
            }}>
            {data.current_floor - 1}
          </Box>
        </Section>
        <Section height="67%" fill>
          {!!data.currently_moving && <MovingDimmer />}
          {/* Hardcoding this height until I can figure out how to do this */}
          <Stack vertical width="90%">
            {data.all_floor_data.map((floor, index) => (
              <Stack.Item key={index}>
                <Button
                  fluid
                  color={'good'}
                  disabled={floor.z_level === data.current_floor}
                  onClick={() => act('move_lift', { z: floor.z_level })}>
                  {floor.name}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
        <Section>
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
                  ? 'In case of emergency, opens all lift doors.'
                  : `The station is only at ${data.emergency_level} alert.`
              }
              onClick={() => act('emergency_door')}>
              Emergency
            </Button>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const NoLiftDimmer = () => {
  return (
    <Dimmer>
      <Stack vertical align="center">
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
      <Stack vertical align="center">
        <Stack.Item>
          <Icon size={8} name="spinner" spin />
        </Stack.Item>
        <Stack.Item fontSize="16px">Moving...</Stack.Item>
      </Stack>
    </Dimmer>
  );
};

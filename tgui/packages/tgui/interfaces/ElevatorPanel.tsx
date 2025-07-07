import {
  Blink,
  Box,
  Button,
  Dimmer,
  Icon,
  Section,
  Stack,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FloorData = {
  name: string;
  z_level: number;
};

type ElevatorPanelData = {
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
  // What floor are we currently moving to?
  currently_moving_to_floor: number | null;
  // A list of all floors we can move around to
  all_floor_data: FloorData[];
};

export const ElevatorPanel = (props) => {
  const { data, act } = useBackend<ElevatorPanelData>();

  const {
    current_floor,
    emergency_level,
    is_emergency,
    doors_open,
    lift_exists,
    currently_moving,
    all_floor_data,
  } = data;

  /*
   * We want to grow our UI if we have a lot of floors to display,
   * while also leaving some whitespace - just so it's not too cluttered.
   *
   * 400 is chosen for the min, to prevent it from being too tiny.
   *
   * 600 is chosen for the max, as it fits 10 floors pretty comfortably.
   * If you seriously need more than 10 floors for an elevator in this game,
   * you should reconsider your map's layout. It's not worth it.
   */
  const calculatedHeight = clamp(all_floor_data.length * 90, 400, 600);

  return (
    <Window width={200} height={calculatedHeight} theme="retro">
      <Window.Content>
        {!lift_exists && <NoLiftDimmer />}
        <Stack height="100%" vertical>
          <Stack.Item>
            <Section title="Floor" align="center">
              <FloorPanel />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill align="center">
              {!!currently_moving && <MovingDimmer />}
              <Stack vertical width="90%">
                {all_floor_data.map((floor, index) => (
                  <Stack.Item key={index}>
                    <Button
                      fontWeight="bold"
                      fontSize="14px"
                      fluid
                      ellipsis
                      textAlign="left"
                      icon="circle"
                      disabled={floor.z_level === current_floor}
                      onClick={() => act('move_lift', { z: floor.z_level })}
                    >
                      {floor.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              {doors_open ? (
                <Button
                  width="65%"
                  icon="door-closed"
                  tooltip={
                    'Closes all elevator doors, except \
                    those on the level of the elevator.'
                  }
                  onClick={() => act('reset_doors')}
                >
                  Reset Doors
                </Button>
              ) : (
                <Button
                  width="65%"
                  icon="door-open"
                  disabled={!is_emergency}
                  color={'bad'}
                  tooltip={
                    is_emergency
                      ? 'In case of emergency, opens all lift doors.'
                      : `The station is only at ${emergency_level} alert.`
                  }
                  onClick={() => act('emergency_door')}
                >
                  Emergency
                </Button>
              )}
            </Section>
          </Stack.Item>
        </Stack>
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

const FloorPanel = (props) => {
  const { data } = useBackend<ElevatorPanelData>();
  const { current_floor, currently_moving, currently_moving_to_floor } = data;

  return (
    <Stack width="50%" backgroundColor="black" align="center">
      <Stack.Item ml={2} mr={1} mt={1} mb={1}>
        <Stack vertical>
          <Stack.Item>
            <ArrowIcon
              icon="arrow-up"
              is_moving={
                currently_moving &&
                currently_moving_to_floor &&
                currently_moving_to_floor > current_floor
              }
            />
          </Stack.Item>
          <Stack.Item>
            <ArrowIcon
              icon="arrow-down"
              is_moving={
                currently_moving &&
                currently_moving_to_floor &&
                currently_moving_to_floor < current_floor
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Box
          textColor="white"
          style={{
            fontFamily: 'Monospace',
            fontSize: '50px',
            fontWeight: 'bold',
          }}
        >
          {current_floor - 1}
        </Box>
      </Stack.Item>
    </Stack>
  );
};

const ArrowIcon = (props) => {
  return props.is_moving ? (
    <Blink time={500} interval={500}>
      <Icon name={props.icon} color={'green'} size={2} />
    </Blink>
  ) : (
    <Icon name={props.icon} color={'grey'} size={2} />
  );
};

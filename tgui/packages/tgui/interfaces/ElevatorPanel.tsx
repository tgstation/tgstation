import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type FloorData = {
  name: string;
  z_level: number;
};

type ElevatorPanelData = {
  panel_z: number;
  emergency_level: string;
  emergency_level_as_num: number;
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
          <Stack vertical align="center" fill>
            <Stack.Item height="50px">
              <Box
                style={{
                  'font-family': 'Consolas',
                  'font-size': '50px',
                }}>
                {data.current_floor}
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
              <Button onClick={() => act('emergency_door')}>Emergency</Button>
              <Button onClick={() => act('reset_doors')}>Reset Doors</Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

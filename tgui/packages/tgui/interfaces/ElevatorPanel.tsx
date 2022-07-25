import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type FloorData = {
  name: string;
  z_level: number;
};

type ElevatorPanelData = {
  lift_exists: BooleanLike;
  currently_moving: BooleanLike;
  current_floor: number;
  all_floor_data: FloorData[];
};

export const AirlockController = (props, context) => {
  const { data } = useBackend<ElevatorPanelData>(context);

  return (
    <Window width={500} height={190}>
      <Window.Content>
        <Section title="Elevator Panel">
          <Stack>
            <Stack.Item>Floor number</Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item>Left buttons</Stack.Item>
                <Stack.Item>Right Buttons</Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>Emergency button?</Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

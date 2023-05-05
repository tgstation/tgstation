import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Stack, Section, ProgressBar } from '../components';

type Modularshieldgendata = {
  max_strength: number;
  current_strength: number;
  regeneration: number;
  max_radius: number;
  current_radius: number;
  active: Boolean;
  recovering: Boolean;
};

export const Modularshieldgen = (props, context) => {
  const { topLevel } = props;
  const { act, data } = useBackend<Modularshieldgendata>(context);
  const {
    max_strength,
    regeneration,
    max_radius,
    current_radius,
    current_strength,
    active,
  } = data;

  return (
    <Window title="Modular Shield Generator" width={600} height={600}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <ProgressBar
                title="Shield Strength"
                rotate={45}
                value={current_strength}
                minValue={0}
                maxValue={max_strength}
                ranges={{
                  'good': [max_strength * 0.85, max_strength],
                  'average': [max_strength * 0.25, max_strength * 0.85],
                  'bad': [0, max_strength * 0.25],
                }}>
                {current_strength}/{max_strength}
              </ProgressBar>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

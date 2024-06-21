import { useBackend } from '../backend';
import { Slider, Button, Stack, Section } from '../components';
import { Window } from '../layouts';

export const ArtifactZapper = (props) => {
  const { act, data } = useBackend();
  const { pulsing, current_strength, max_strength } = data;
  return (
    <Window width={400} height={110}>
      <Window.Content>
        <Section title="Status" textAlign="center">
          <Stack fill>
            <Stack.Item grow>
              <Slider
                minValue={100}
                maxValue={max_strength}
                value={current_strength}
                stepPixelSize={25}
                step={100}
                unit={'Shock Strength'}
                onDrag={(e, nu) => act('strength', { target: nu })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content={'Shock'}
                disabled={pulsing}
                color="green"
                onClick={() => act('shock')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

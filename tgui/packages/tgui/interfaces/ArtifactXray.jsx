import { useBackend } from '../backend';
import { Slider, Button, Stack, NoticeBox, Section, Box } from '../components';
import { Window } from '../layouts';

export const ArtifactXray = (props) => {
  const { act, data } = useBackend();
  const {
    is_open,
    artifact_name,
    pulsing,
    current_strength,
    max_strength,
    results,
  } = data;
  return (
    <Window width={400} height={220}>
      <Window.Content>
        <Section
          title="X-Ray Status"
          textAlign="center"
          buttons={
            <Button
              content={is_open ? 'Close' : 'Open'}
              selected={!is_open}
              onClick={() => act('toggleopen')}
            />
          }
        >
          {(!artifact_name && <NoticeBox>No artifact detected.</NoticeBox>) || (
            <>
              <Box color="label" mt={1}>
                <b>Currently loaded object:</b> {artifact_name}
              </Box>
              <Stack fill>
                <Stack.Item grow>
                  <Slider
                    minValue={1}
                    maxValue={max_strength}
                    value={current_strength}
                    stepPixelSize={35}
                    step={1}
                    unit={'Pulse Strength'}
                    onDrag={(e, nu) => act('change_rate', { target: nu })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content={'Pulse'}
                    disabled={is_open || pulsing}
                    color="green"
                    onClick={() => act('pulse')}
                  />
                </Stack.Item>
              </Stack>
            </>
          )}
          <Section title={'Last Scan Results'} backgroundColor="black">
            {results.map((result) => (
              <Box mb={1} key={result} color="green">
                {result}
              </Box>
            ))}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};

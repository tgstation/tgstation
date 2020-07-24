import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, Grid, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const Signaler = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    code,
    frequency,
    minFrequency,
    maxFrequency,
  } = data;
  return (
    <Window
      width={280}
      height={132}>
      <Window.Content>
        <Section>
          <Grid>
            <Grid.Column size={1.4} color="label">
              Frequency:
            </Grid.Column>
            <Grid.Column>
              <NumberInput
                animate
                unit="kHz"
                step={0.2}
                stepPixelSize={6}
                minValue={minFrequency / 10}
                maxValue={maxFrequency / 10}
                value={frequency / 10}
                format={value => toFixed(value, 1)}
                width="80px"
                onDrag={(e, value) => act('freq', {
                  freq: value,
                })} />
            </Grid.Column>
            <Grid.Column>
              <Button
                ml={1.3}
                icon="sync"
                content="Reset"
                onClick={() => act('reset', {
                  reset: "freq",
                })} />
            </Grid.Column>
          </Grid>
          <Grid mt={0.6}>
            <Grid.Column size={1.4} color="label">
              Code:
            </Grid.Column>
            <Grid.Column>
              <NumberInput
                animate
                step={1}
                stepPixelSize={6}
                minValue={1}
                maxValue={100}
                value={code}
                width="80px"
                onDrag={(e, value) => act('code', {
                  code: value,
                })} />
            </Grid.Column>
            <Grid.Column>
              <Button
                ml={1.3}
                icon="sync"
                content="Reset"
                onClick={() => act('reset', {
                  reset: "code",
                })} />
            </Grid.Column>
          </Grid>
          <Grid mt={0.8}>
            <Grid.Column>
              <Button
                mb={-0.1}
                fluid
                icon="arrow-up"
                content="Send Signal"
                textAlign="center"
                onClick={() => act('signal')} />
            </Grid.Column>
          </Grid>
        </Section>
      </Window.Content>
    </Window>
  );
};

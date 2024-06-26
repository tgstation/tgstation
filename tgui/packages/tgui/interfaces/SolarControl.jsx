import { useBackend } from '../backend';
import {
  Box,
  Button,
  Grid,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const SolarControl = (props) => {
  const { act, data } = useBackend();
  const {
    generated,
    generated_ratio,
    azimuth_current,
    azimuth_rate,
    max_rotation_rate,
    tracking_state,
    connected_panels,
    connected_tracker,
  } = data;
  return (
    <Window width={380} height={230}>
      <Window.Content>
        <Section
          title="Status"
          buttons={
            <Button
              icon="sync"
              content="Scan for new hardware"
              onClick={() => act('refresh')}
            />
          }
        >
          <Grid>
            <Grid.Column>
              <LabeledList>
                <LabeledList.Item
                  label="Solar tracker"
                  color={connected_tracker ? 'good' : 'bad'}
                >
                  {connected_tracker ? 'OK' : 'N/A'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Solar panels"
                  color={connected_panels > 0 ? 'good' : 'bad'}
                >
                  {connected_panels}
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
            <Grid.Column size={1.5}>
              <LabeledList>
                <LabeledList.Item label="Power output">
                  <ProgressBar
                    ranges={{
                      good: [0.66, Infinity],
                      average: [0.33, 0.66],
                      bad: [-Infinity, 0.33],
                    }}
                    minValue={0}
                    maxValue={1}
                    value={generated_ratio}
                  >
                    {generated + ' W'}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
          </Grid>
        </Section>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Tracking">
              <Button
                icon="times"
                content="Off"
                selected={tracking_state === 0}
                onClick={() => act('tracking', { mode: 0 })}
              />
              <Button
                icon="clock-o"
                content="Timed"
                selected={tracking_state === 1}
                onClick={() => act('tracking', { mode: 1 })}
              />
              <Button
                icon="sync"
                content="Auto"
                selected={tracking_state === 2}
                disabled={!connected_tracker}
                onClick={() => act('tracking', { mode: 2 })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Azimuth">
              {(tracking_state === 0 || tracking_state === 1) && (
                <NumberInput
                  width="52px"
                  unit="°"
                  step={1}
                  stepPixelSize={2}
                  minValue={-360}
                  maxValue={+720}
                  value={azimuth_current}
                  onDrag={(e, value) => act('azimuth', { value })}
                />
              )}
              {tracking_state === 1 && (
                <NumberInput
                  width="80px"
                  unit="°/m"
                  step={0.01}
                  stepPixelSize={1}
                  minValue={-max_rotation_rate - 0.01}
                  maxValue={max_rotation_rate + 0.01}
                  value={azimuth_rate}
                  format={(rate) => {
                    const sign = Math.sign(rate) > 0 ? '+' : '-';
                    return sign + Math.abs(rate);
                  }}
                  onDrag={(e, value) => act('azimuth_rate', { value })}
                />
              )}
              {tracking_state === 2 && (
                <Box inline color="label" mt="3px">
                  {azimuth_current + ' °'} (auto)
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

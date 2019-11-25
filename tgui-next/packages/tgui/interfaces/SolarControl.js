import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, Grid, LabeledList, NumberInput, ProgressBar, Section } from '../components';

export const SolarControl = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    generated,
    angle,
    tracking_state,
    tracking_rate,
    connected_panels,
    connected_tracker,
  } = data;
  return (
    <Fragment>
      <Section
        title="Status"
        buttons={(
          <Button
            icon="sync"
            content="Scan for new hardware"
            onClick={() => act(ref, 'refresh')} />
        )}>
        <Grid>
          <Grid.Column>
            <LabeledList>
              <LabeledList.Item
                label="Solar tracker"
                color={connected_tracker ? 'good' : 'bad'}>
                {connected_tracker ? 'OK' : 'N/A'}
              </LabeledList.Item>
              <LabeledList.Item
                label="Solar panels"
                color={connected_panels > 0 ? 'good' : 'bad'}>
                {connected_panels}
              </LabeledList.Item>
            </LabeledList>
          </Grid.Column>
          <Grid.Column size={1.5}>
            <LabeledList>
              <LabeledList.Item label="Power output">
                <ProgressBar
                  ranges={{
                    good: [60000, Infinity],
                    average: [30000, 60000],
                    bad: [-Infinity, 30000],
                  }}
                  minValue={0}
                  maxValue={90000}
                  value={generated}
                  content={generated + ' W'} />
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
              onClick={() => act(ref, 'tracking', { mode: 0 })} />
            <Button
              icon="clock-o"
              content="Timed"
              selected={tracking_state === 1}
              onClick={() => act(ref, 'tracking', { mode: 1 })} />
            <Button
              icon="sync"
              content="Auto"
              selected={tracking_state === 2}
              disabled={!connected_tracker}
              onClick={() => act(ref, 'tracking', { mode: 2 })} />
          </LabeledList.Item>
          <LabeledList.Item label="Angle">
            {(tracking_state === 0 || tracking_state === 1) && (
              <NumberInput
                width="52px"
                unit="°"
                step={1}
                stepPixelSize={2}
                minValue={-360}
                maxValue={+720}
                value={angle}
                format={angle => Math.round(360 + angle) % 360}
                onDrag={(e, value) => act(ref, 'angle', { value })} />
            )}
            {tracking_state === 1 && (
              <NumberInput
                width="80px"
                unit="°/h"
                step={5}
                stepPixelSize={2}
                minValue={-7200}
                maxValue={7200}
                value={tracking_rate}
                format={rate => {
                  const sign = Math.sign(rate) > 0 ? '+' : '-';
                  return sign + toFixed(Math.abs(rate));
                }}
                onDrag={(e, value) => act(ref, 'rate', { value })} />
            )}
            {tracking_state === 2 && (
              <Box inline color="label" mt="3px">
                {angle + ' °'} (auto)
              </Box>
            )}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

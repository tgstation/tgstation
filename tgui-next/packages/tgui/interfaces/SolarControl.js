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
    max_generated,
    azimuth_current,
    elevation_current,
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
                  maxValue={max_generated}
                  value={generated}
                  content={generated + ' W'} />
              </LabeledList.Item>
            </LabeledList>
          </Grid.Column>
        </Grid>
      </Section>
      {!!connected_tracker && (
        <Section title="Tracker">
          <LabeledList>
            <LabeledList.Item label="Azimuth">
              <Box inline color="label" mt="3px">
                {azimuth_current + ' °'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Elevation">
              <Box inline color="label" mt="3px">
                {elevation_current + ' °'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Fragment>
  );
};

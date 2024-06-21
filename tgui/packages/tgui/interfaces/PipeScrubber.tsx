import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledControls,
  RoundGauge,
  Section,
} from '../components';
import { getGasLabel } from '../constants';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  direction: BooleanLike;
  connected: BooleanLike;
  pressure: number;
  maxPressure: number;
  hasHypernobCrystal: BooleanLike;
  reactionSuppressionEnabled: BooleanLike;
  filterTypes: Filter[];
};

type Filter = {
  id: string;
  enabled: BooleanLike;
  gasId: string;
  gasName: string;
};

const formatPressure = (value) => {
  if (value < 10000) {
    return toFixed(value) + ' kPa';
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

export const PipeScrubber = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    connected,
    direction,
    pressure,
    maxPressure,
    hasHypernobCrystal,
    reactionSuppressionEnabled,
    filterTypes = [],
  } = data;

  return (
    <Window width={400} height={360}>
      <Window.Content>
        <Section
          title="Status"
          buttons={
            !!hasHypernobCrystal && (
              <Button
                icon={reactionSuppressionEnabled ? 'snowflake' : 'times'}
                selected={reactionSuppressionEnabled}
                onClick={() => act('reaction_suppression')}
              >
                {reactionSuppressionEnabled
                  ? 'Reaction Suppression Enabled'
                  : 'Reaction Suppression Disabled'}
              </Button>
            )
          }
        >
          <LabeledControls p={2}>
            <LabeledControls.Item label="Tank Pressure">
              <RoundGauge
                size={2.5}
                value={pressure}
                minValue={0}
                maxValue={maxPressure}
                ranges={{
                  good: [0, maxPressure * 0.5],
                  average: [maxPressure * 0.5, maxPressure * 0.8],
                  bad: [maxPressure * 0.8, maxPressure],
                }}
                format={formatPressure}
              />
            </LabeledControls.Item>
            <LabeledControls.Item
              mr={1}
              label={connected ? 'Port Connected' : 'Port Disconnected'}
            >
              <Box position="relative">
                <Icon
                  size={3}
                  name={connected ? 'plug' : 'times'}
                  color={connected ? 'good' : 'bad'}
                />
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Pump">
              <Button
                my={0.5}
                lineHeight={2}
                fontSize="18px"
                icon="power-off"
                disabled={!connected}
                selected={on}
                onClick={() => act('power')}
              >
                {on ? 'On' : 'Off'}
              </Button>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section
          title="Direction"
          buttons={
            <Button onClick={() => act('direction')}>
              {direction ? 'Port → Tank' : 'Tank → Port'}
            </Button>
          }
        >
          {!!direction && (
            <>
              <Box>Filtering gases from the port into the internal tank.</Box>
              <Section>
                {filterTypes.map((filter) => (
                  <Button
                    key={filter.id}
                    icon={filter.enabled ? 'check-square-o' : 'square-o'}
                    content={getGasLabel(filter.gasId, filter.gasName)}
                    selected={filter.enabled}
                    onClick={() =>
                      act('toggle_filter', {
                        val: filter.gasId,
                      })
                    }
                  />
                ))}
              </Section>
            </>
          )}
          {!direction && <Box>Dumping internal tank gases into the port.</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};

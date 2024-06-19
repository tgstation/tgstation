import { capitalize } from 'common/string';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const SpaceHeater = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={400} height={305}>
      <Window.Content>
        <Section
          title="Power"
          buttons={
            <>
              {!!data.chemHacked && (
                <Button
                  icon="eject"
                  content="Eject beaker"
                  disabled={!data.beaker}
                  onClick={() => act('ejectBeaker')}
                />
              )}
              <Button
                icon="eject"
                content="Eject Cell"
                disabled={!data.hasPowercell || !data.open}
                onClick={() => act('eject')}
              />
              <Button
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? 'On' : 'Off'}
                selected={data.on}
                disabled={!data.hasPowercell}
                onClick={() => act('power')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Cell" color={!data.hasPowercell && 'bad'}>
              {(data.hasPowercell && (
                <ProgressBar
                  value={data.powerLevel / 100}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }}
                >
                  {data.powerLevel + '%'}
                </ProgressBar>
              )) ||
                'None'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Thermostat">
          <LabeledList>
            <LabeledList.Item label="Current Temperature">
              <Box
                fontSize="18px"
                color={
                  Math.abs(data.targetTemp - data.currentTemp) > 50
                    ? 'bad'
                    : Math.abs(data.targetTemp - data.currentTemp) > 20
                      ? 'average'
                      : 'good'
                }
              >
                {data.currentTemp}°C
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Target Temperature">
              {(data.open && (
                <NumberInput
                  animated
                  value={parseFloat(data.targetTemp)}
                  width="65px"
                  unit="°C"
                  step={1}
                  minValue={data.minTemp}
                  maxValue={data.maxTemp}
                  onChange={(value) =>
                    act('target', {
                      target: value,
                    })
                  }
                />
              )) ||
                data.targetTemp + '°C'}
            </LabeledList.Item>
            <LabeledList.Item label="Mode">
              {(!data.open && capitalize(data.mode)) || (
                <>
                  <Button
                    icon="thermometer-half"
                    content="Auto"
                    selected={data.mode === 'auto'}
                    onClick={() =>
                      act('mode', {
                        mode: 'auto',
                      })
                    }
                  />
                  <Button
                    icon="fire-alt"
                    content="Heat"
                    selected={data.mode === 'heat'}
                    onClick={() =>
                      act('mode', {
                        mode: 'heat',
                      })
                    }
                  />
                  <Button
                    icon="fan"
                    content="Cool"
                    selected={data.mode === 'cool'}
                    onClick={() =>
                      act('mode', {
                        mode: 'cool',
                      })
                    }
                  />
                </>
              )}
            </LabeledList.Item>
            <LabeledList.Divider />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

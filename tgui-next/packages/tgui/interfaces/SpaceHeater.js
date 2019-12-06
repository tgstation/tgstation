import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, ProgressBar, Section } from '../components';

export const SpaceHeater = props => {
  const { act, data } = useBackend(props);
  return (
    <Fragment>
      <Section
        title="Power"
        buttons={(
          <Fragment>
            <Button
              icon="eject"
              content="Eject Cell"
              disabled={!data.hasPowercell || !data.open}
              onClick={() => act('eject')} />
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? 'On' : 'Off'}
              selected={data.on}
              disabled={!data.hasPowercell}
              onClick={() => act('power')} />
          </Fragment>
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Cell"
            color={!data.hasPowercell && 'bad'}>
            {data.hasPowercell && (
              <ProgressBar
                value={data.powerLevel / 100}
                content={data.powerLevel + '%'}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [-Infinity, 0.3],
                }} />
            ) || 'None'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Thermostat">
        <LabeledList>
          <LabeledList.Item label="Current Temperature">
            <Box
              fontSize="18px"
              color={Math.abs(data.targetTemp - data.currentTemp) > 50
                ? 'bad'
                : Math.abs(data.targetTemp - data.currentTemp) > 20
                  ? 'average'
                  : 'good'}>
              {data.currentTemp}°C
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Target Temperature">
            {data.open && (
              <NumberInput
                animated
                value={parseFloat(data.targetTemp)}
                width="65px"
                unit="°C"
                minValue={data.minTemp}
                maxValue={data.maxTemp}
                onChange={(e, value) => act('target', {
                  target: value,
                })} />
            ) || (
              data.targetTemp + '°C'
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Mode">
            {!data.open && 'Auto' || (
              <Fragment>
                <Button
                  icon="thermometer-half"
                  content="Auto"
                  selected={data.mode === 'auto'}
                  onClick={() => act('mode', {
                    mode: "auto",
                  })} />
                <Button
                  icon="fire-alt"
                  content="Heat"
                  selected={data.mode === 'heat'}
                  onClick={() => act('mode', {
                    mode: "heat",
                  })} />
                <Button
                  icon="fan"
                  content="Cool"
                  selected={data.mode === 'cool'}
                  onClick={() => act('mode', {
                    mode: 'cool',
                  })} />
              </Fragment>
            )}
          </LabeledList.Item>
          <LabeledList.Divider />
        </LabeledList>
      </Section>
    </Fragment>
  );
};

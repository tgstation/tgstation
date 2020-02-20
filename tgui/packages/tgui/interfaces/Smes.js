import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, NumberInput, LabeledList, ProgressBar, Section } from '../components';

export const Smes = props => {
  const { act, data } = useBackend(props);

  let inputState;
  if (data.capacityPercent >= 100) {
    inputState = 'good';
  }
  else if (data.inputting) {
    inputState = 'average';
  }
  else {
    inputState = 'bad';
  }
  let outputState;
  if (data.outputting) {
    outputState = 'good';
  }
  else if (data.charge > 0) {
    outputState = 'average';
  }
  else {
    outputState = 'bad';
  }

  return (
    <Fragment>
      <Section title="Stored Energy">
        <ProgressBar
          value={data.capacityPercent * 0.01}
          ranges={{
            good: [0.5, Infinity],
            average: [0.15, 0.5],
            bad: [-Infinity, 0.15],
          }} />
      </Section>
      <Section title="Input">
        <LabeledList>
          <LabeledList.Item
            label="Charge Mode"
            buttons={
              <Button
                icon={data.inputAttempt ? 'sync-alt' : 'times'}
                selected={data.inputAttempt}
                onClick={() => act('tryinput')}>
                {data.inputAttempt ? 'Auto' : 'Off'}
              </Button>
            }>
            <Box color={inputState}>
              {data.capacityPercent >= 100
                ? 'Fully Charged'
                : data.inputting
                  ? 'Charging'
                  : 'Not Charging'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Target Input">
            <ProgressBar
              value={data.inputLevel/data.inputLevelMax}
              content={data.inputLevel_text} />
          </LabeledList.Item>
          <LabeledList.Item label="Adjust Input">
            <Button
              icon="fast-backward"
              disabled={data.inputLevel === 0}
              onClick={() => act('input', {
                target: 'min',
              })} />
            <Button
              icon="backward"
              disabled={data.inputLevel === 0}
              onClick={() => act('input', {
                adjust: -10000,
              })} />
            <NumberInput
              value={Math.round(data.inputLevel/1000)}
              unit="kW"
              width="65px"
              minValue={0}
              maxValue={data.inputLevelMax/1000}
              onChange={(e, value) => {
                return act('input', {
                  target: value*1000,
                });
              }} />
            <Button
              icon="forward"
              disabled={data.inputLevel === data.inputLevelMax}
              onClick={() => act('input', {
                adjust: 10000,
              })} />
            <Button
              icon="fast-forward"
              disabled={data.inputLevel === data.inputLevelMax}
              onClick={() => act('input', {
                target: 'max',
              })} />
          </LabeledList.Item>
          <LabeledList.Item label="Available">
            {data.inputAvailable}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Output">
        <LabeledList>
          <LabeledList.Item
            label="Output Mode"
            buttons={
              <Button
                icon={data.outputAttempt ? 'power-off' : 'times'}
                selected={data.outputAttempt}
                onClick={() => act('tryoutput')}>
                {data.outputAttempt ? 'On' : 'Off'}
              </Button>
            }>
            <Box color={outputState}>
              {data.outputting
                ? 'Sending'
                : data.charge > 0
                  ? 'Not Sending'
                  : 'No Charge'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Target Output">
            <ProgressBar
              value={data.outputLevel/data.outputLevelMax}
              content={data.outputLevel_text} />
          </LabeledList.Item>
          <LabeledList.Item label="Adjust Output">
            <Button
              icon="fast-backward"
              disabled={data.outputLevel === 0}
              onClick={() => act('output', {
                target: 'min',
              })} />
            <Button
              icon="backward"
              disabled={data.outputLevel === 0}
              onClick={() => act('output', {
                adjust: -10000,
              })} />
            <NumberInput
              value={Math.round(data.outputLevel/1000)}
              unit="kW"
              width="65px"
              minValue={0}
              maxValue={data.outputLevelMax/1000}
              onChange={(e, value) => {
                return act('output', {
                  target: value*1000,
                });
              }} />
            <Button
              icon="forward"
              disabled={data.outputLevel === data.outputLevelMax}
              onClick={() => act('output', {
                adjust: 10000,
              })} />
            <Button
              icon="fast-forward"
              disabled={data.outputLevel === data.outputLevelMax}
              onClick={() => act('output', {
                target: 'max',
              })} />
          </LabeledList.Item>
          <LabeledList.Item label="Outputting">
            {data.outputUsed}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

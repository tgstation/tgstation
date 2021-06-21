import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Modal, NumberInput, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const TurbineController = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={300}
      height={400}>
      <Window.Content>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Start Machine">
              <Button
                content={data.on ? 'ON' : 'OFF'}
                color={data.on ? "green" : "red"}
                onClick={() => act('on')} />
            </LabeledList.Item>
            <LabeledList.Item label="Disconnect All">
              <Button
                content={'Disconnect'}
                color={"red"}
                disabled={!data.connected || data.on}
                onClick={() => act('disconnect')} />
            </LabeledList.Item>
            <LabeledList.Item label="Input ratio">
              <NumberInput
                animated
                value={data.input_ratio}
                unit="%"
                width="62px"
                minValue={0}
                maxValue={100}
                onDrag={(e, value) => act('target', {
                  target: value,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Power Generation">
          <LabeledList>
            <LabeledList.Item label="RPM">
              <AnimatedNumber
                value={data.rpm}
                format={value => toFixed(value, 2)} />
              {' rmp'}
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <AnimatedNumber
                value={data.powergen * 0.001} />
              {' KW / Tick'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Current Gas Flow">
          <LabeledList>
            <LabeledList.Item label="Input Pressure">
              <AnimatedNumber
                value={data.first_pressure}
                format={value => toFixed(value, 2)} />
              {' Kpa'}
            </LabeledList.Item>
            <LabeledList.Item label="Input Temperature">
              <AnimatedNumber
                value={data.first_temperature}
                format={value => toFixed(value, 2)} />
              {' K'}
            </LabeledList.Item>
            <LabeledList.Item label="Output Pressure">
              <AnimatedNumber
                value={data.second_pressure}
                format={value => toFixed(value, 2)} />
              {' Kpa'}
            </LabeledList.Item>
            <LabeledList.Item label="Output Temperature">
              <AnimatedNumber
                value={data.second_temperature}
                format={value => toFixed(value, 2)} />
              {' K'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

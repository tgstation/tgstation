import { NumberInput, Button, Section, LabeledList } from '../components';
import { useBackend } from '../backend';
import { toFixed } from 'common/math';

export const Signaler = props => {
  const { act, data } = useBackend(props);
  const {
    code,
    frequency,
    minFrequency,
    maxFrequency,
  } = data;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Frequency">
          <NumberInput
            animate
            unit="kHz"
            step={0.2}
            stepPixelSize={6}
            minValue={minFrequency / 10}
            maxValue={maxFrequency / 10}
            value={frequency / 10}
            format={value => toFixed(value, 1)}
            width={13}
            onDrag={(e, value) => act('freq', {
              freq: value,
            })} />
          <Button
            ml={0.5}
            icon="sync"
            content="Reset"
            onClick={() => act('reset', {
              reset: "freq",
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Code">
          <NumberInput
            animate
            step={1}
            stepPixelSize={6}
            minValue={1}
            maxValue={100}
            value={code}
            width={13}
            onDrag={(e, value) => act('code', {
              code: value,
            })} />
          <Button
            ml={0.5}
            icon="sync"
            content="Reset"
            onClick={() => act('reset', {
              reset: "code",
            })} />
        </LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        mb={-0.2}
        width={37.4}
        icon="arrow-up"
        content="Send Signal"
        textAlign="center"
        onClick={() => act('signal')} />
    </Section>
  );
};

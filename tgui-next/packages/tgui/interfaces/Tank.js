import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, ProgressBar, Section } from '../components';

export const Tank = props => {
  const { act, data } = useBackend(props);
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Pressure">
          <ProgressBar
            value={data.tankPressure / 1013}
            content={data.tankPressure + ' kPa'}
            ranges={{
              good: [0.35, Infinity],
              average: [0.15, 0.35],
              bad: [-Infinity, 0.15],
            }} />
        </LabeledList.Item>
        <LabeledList.Item label="Pressure Regulator">
          <Button
            icon="fast-backward"
            disabled={data.ReleasePressure === data.minReleasePressure}
            onClick={() => act('pressure', {
              pressure: 'min',
            })} />
          <NumberInput
            animated
            value={parseFloat(data.releasePressure)}
            width="65px"
            unit="kPa"
            minValue={data.minReleasePressure}
            maxValue={data.maxReleasePressure}
            onChange={(e, value) => act('pressure', {
              pressure: value,
            })} />
          <Button
            icon="fast-forward"
            disabled={data.ReleasePressure === data.maxReleasePressure}
            onClick={() => act('pressure', {
              pressure: 'max',
            })} />
          <Button
            icon="undo"
            content=""
            disabled={data.ReleasePressure === data.defaultReleasePressure}
            onClick={() => act('pressure', {
              pressure: 'reset',
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

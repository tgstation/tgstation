import { Fragment } from 'inferno';
import { act } from '../byond';
import { Section, ProgressBar, LabeledList, Button, NumberInput } from '../components';
import { LabeledListItem } from '../components/LabeledList';

export const Tank = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section>
      <LabeledList>
        <LabeledListItem label="Pressure">
          <ProgressBar
            value={data.tankPressure / 1013}
            content={data.tankPressure + ' kPa'}
            ranges={{
              good: [0.35, Infinity],
              average: [0.15, 0.35],
              bad: [-Infinity, 0.15],
            }}
          />
        </LabeledListItem>
        <LabeledListItem label="Pressure Regulator">
          <Button
            icon="fast-backward"
            disabled={data.ReleasePressure === data.minReleasePressure}
            onClick={() => act(ref, 'pressure', {
              pressure: 'min',
            })} />
          <NumberInput
            animated
            value={parseFloat(data.releasePressure)}
            width="65px"
            unit="kPa"
            minValue={data.minReleasePressure}
            maxValue={data.maxReleasePressure}
            onChange={(e, value) => act(ref, 'pressure', {
              pressure: value,
            })} />
          <Button
            icon="fast-forward"
            disabled={data.ReleasePressure === data.maxReleasePressure}
            onClick={() => act(ref, 'pressure', {
              pressure: 'max',
            })} />
          <Button
            icon="undo"
            content=""
            disabled={data.ReleasePressure === data.defaultReleasePressure}
            onClick={() => act(ref, 'pressure', {
              pressure: 'reset',
            })} />
        </LabeledListItem>
      </LabeledList>
    </Section>
  );
};

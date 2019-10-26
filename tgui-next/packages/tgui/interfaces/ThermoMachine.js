import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, LabeledList, Button, Section } from '../components';
import { toFixed } from 'common/math';
import { NumberInput } from '../components/NumberInput';

export const ThermoMachine = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Temperature">
            <AnimatedNumber
              value={data.temperature}
              format={value => toFixed(value, 2)} />
            {' K'}
          </LabeledList.Item>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber
              value={data.pressure}
              format={value => toFixed(value, 2)} />
            {' kPa'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Controls"
        buttons={(
          <Button
            icon={data.on ? 'power-off' : 'times'}
            content={data.on ? 'On' : 'Off'}
            selected={data.on}
            onClick={() => act(ref, 'power')}
          />
        )}
      >
        <LabeledList>
          <LabeledList.Item label="Target Temperature">
            <NumberInput
              value={Math.round(data.target)}
              unit="K"
              width="59px"
              minValue={Math.round(data.min)}
              maxValue={Math.round(data.max)}
              step={5}
              onChange={(e, value) => act(ref, "target", {target: value})}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Presets">
            <Button
              icon="minus"
              disabled={data.target === data.min}
              tooltip="Minimum temperature"
              tooltipPosition="top"
              onClick={() => act(ref, "target", {target: data.min})}
            />
            <Button
              icon="sync"
              disabled={data.target === data.initial}
              tooltip="Room Temperature"
              tooltipPosition="top"
              onClick={() => act(ref, "target", {target: data.initial})}
            />
            <Button
              icon="plus"
              disabled={data.target === data.max}
              tooltip="Maximum Temperature"
              tooltipPosition="top"
              onClick={() => act(ref, "target", {target: data.max})}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

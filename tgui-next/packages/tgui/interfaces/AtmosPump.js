import { act } from '../byond';
import { Button, LabeledList, Section } from '../components';
import { NumberInput } from '../components/NumberInput';
import { Fragment } from 'inferno';

export const AtmosPump = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={data.on ? 'power-off' : 'times'}
            content={data.on ? 'On' : 'Off'}
            selected={data.on}
            onClick={() => act(ref, 'power')} />
        </LabeledList.Item>
        {data.max_rate ? (
          <LabeledList.Item label="Transfer Rate">
            <NumberInput
              value={parseFloat(data.rate)}
              width="62px"
              unit={"L/s"}
              minValue={0}
              maxValue={200}
              onChange={(e, value) => act(ref, 'rate', {rate: value})}
            />
            <Button
              icon="plus"
              content="Max"
              disabled={data.rate === data.max_rate}
              onClick={() => act(ref, 'rate', {rate: 'max'})}
            />
          </LabeledList.Item>
        ) : (
          <LabeledList.Item label="Output Pressure">
            <NumberInput
              value={parseFloat(data.pressure)}
              unit="kPa"
              width="73px"
              minValue={0}
              maxValue={4500}
              step={10}
              onChange={(e, value) => act(ref, 'pressure', {pressure: value})}
            />
            <Button
              icon="plus"
              content="Max"
              disabled={data.pressure === data.max_pressure}
              onClick={() => act(ref, 'pressure', { pressure: 'max' })}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, Section } from '../components';
import { NumberInput } from '../components/NumberInput';

export const AtmosMixer = props => {
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
            onClick={() => act(ref, 'power')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Output Pressure">
          <NumberInput
            value={parseFloat(data.set_pressure)}
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
            disabled={data.set_pressure === data.max_pressure}
            onClick={() => act(ref, 'pressure', { pressure: 'max' })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Node 1">
          <NumberInput
            value={data.node1_concentration}
            unit="%"
            width="56px"
            minValue={0}
            maxValue={100}
            onDrag={(e, value) => act(ref, "node1", {concentration: value})}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Node 2">
          <NumberInput
            value={data.node2_concentration}
            unit="%"
            width="56px"
            minValue={0}
            maxValue={100}
            onDrag={(e, value) => act(ref, "node2", {concentration: value})}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

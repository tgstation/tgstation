import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, Section } from '../components';
import { NumberInput } from '../components/NumberInput';

export const AtmosFilter = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const filterTypes = data.filter_types || [];
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
            onClick={() => act(ref, 'rate', {rate: 'max'})} />
        </LabeledList.Item>
        <LabeledList.Item label="Filter">
          {filterTypes.map(filter => (
            <Button
              key={filter.id}
              selected={filter.selected}
              content={filter.name}
              onClick={() => act(ref, 'filter', {
                mode: filter.id,
              })} />
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

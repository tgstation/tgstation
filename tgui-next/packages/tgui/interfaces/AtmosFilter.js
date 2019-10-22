import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, Section } from '../components';

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
          <Button
            icon="pencil-alt"
            content="Set"
            onClick={() => act(ref, 'rate', {rate: 'input'})} />
          <Button
            icon="plus"
            content="Max"
            disabled={data.rate === data.max_rate}
            onClick={() => act(ref, 'rate', {rate: 'max'})} />
          {' '}
          <AnimatedNumber value={parseFloat(data.rate)} />
          {' L/s'}
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

import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';

export const AtmosFilter = (props, context) => {
  const { act, data } = useBackend(context);
  const filterTypes = data.filter_types || [];
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? 'On' : 'Off'}
                selected={data.on}
                onClick={() => act('power')} />
            </LabeledList.Item>
            <LabeledList.Item label="Transfer Rate">
              <NumberInput
                animated
                value={parseFloat(data.rate)}
                width="63px"
                unit="L/s"
                minValue={0}
                maxValue={200}
                onDrag={(e, value) => act('rate', {
                  rate: value,
                })} />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={data.rate === data.max_rate}
                onClick={() => act('rate', {
                  rate: 'max',
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Filter">
              {filterTypes.map(filter => (
                <Button
                  key={filter.id}
                  selected={filter.selected}
                  content={getGasLabel(filter.id, filter.name)}
                  onClick={() => act('filter', {
                    mode: filter.id,
                  })} />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

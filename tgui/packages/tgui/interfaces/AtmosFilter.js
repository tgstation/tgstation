import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';

export const AtmosFilter = (props, context) => {
  const { act, data } = useBackend(context);
  const filter_types = data.filter_types || [];
  return (
    <Window width={420} height={221}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? 'On' : 'Off'}
                selected={data.on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Transfer Rate">
              <NumberInput
                animated
                value={parseFloat(data.rate)}
                width="63px"
                unit="L/s"
                minValue={0}
                maxValue={data.max_rate}
                onDrag={(e, value) =>
                  act('rate', {
                    rate: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={data.rate === data.max_rate}
                onClick={() =>
                  act('rate', {
                    rate: 'max',
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Filters">
              {filter_types.map((filter) => (
                <Button
                  key={filter.id}
                  icon={filter.enabled ? 'check-square-o' : 'square-o'}
                  content={getGasLabel(filter.gas_id, filter.gas_name)}
                  selected={filter.enabled}
                  onClick={() =>
                    act('toggle_filter', {
                      val: filter.gas_id,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';

type Data = {
  filter_types: Filter[];
  on: BooleanLike;
  rate: number;
  max_rate: number;
};

type Filter = {
  id: number;
  enabled: BooleanLike;
  gas_id: number;
  gas_name: string;
};

export const AtmosFilter = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { filter_types = [], on, rate, max_rate } = data;

  return (
    <Window width={420} height={221}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Transfer Rate">
              <NumberInput
                animated
                value={rate}
                width="63px"
                unit="L/s"
                minValue={0}
                maxValue={max_rate}
                onDrag={(_, value) =>
                  act('rate', {
                    rate: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={rate === max_rate}
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

import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  temperature: number;
  min_temperature: number;
  max_temperature: number;
};

export const AtmosTempGate = (props) => {
  const { act, data } = useBackend<Data>();
  const { on, temperature, min_temperature, max_temperature } = data;

  return (
    <Window width={335} height={115}>
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
            <LabeledList.Item label="Heat settings">
              <NumberInput
                animated
                value={temperature}
                unit="K"
                width="75px"
                minValue={min_temperature}
                maxValue={max_temperature}
                step={1}
                onChange={(value) =>
                  act('temperature', {
                    temperature: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={temperature === max_temperature}
                onClick={() =>
                  act('temperature', {
                    temperature: 'max',
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

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
  max_rate: number;
  rate: number;
  pressure: number;
  max_pressure: number;
};

export const AtmosPump = (props) => {
  const { act, data } = useBackend<Data>();
  const { on, max_rate, max_pressure, rate, pressure } = data;

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
            {max_rate ? (
              <LabeledList.Item label="Transfer Rate">
                <NumberInput
                  animated
                  value={rate}
                  step={1}
                  width="63px"
                  unit="L/s"
                  minValue={0}
                  maxValue={max_rate}
                  onChange={(value) =>
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
            ) : (
              <LabeledList.Item label="Output Pressure">
                <NumberInput
                  animated
                  value={pressure}
                  unit="kPa"
                  width="75px"
                  minValue={0}
                  maxValue={max_pressure}
                  step={10}
                  onChange={(value) =>
                    act('pressure', {
                      pressure: value,
                    })
                  }
                />
                <Button
                  ml={1}
                  icon="plus"
                  content="Max"
                  disabled={pressure === max_pressure}
                  onClick={() =>
                    act('pressure', {
                      pressure: 'max',
                    })
                  }
                />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

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
  set_pressure: number;
  max_pressure: number;
  node1_concentration: number;
  node2_concentration: number;
};

export const AtmosMixer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    set_pressure,
    max_pressure,
    node1_concentration,
    node2_concentration,
  } = data;

  return (
    <Window width={370} height={165}>
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
            <LabeledList.Item label="Output Pressure">
              <NumberInput
                animated
                value={set_pressure}
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
                disabled={set_pressure === max_pressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Main Node" labelColor="green">
              <NumberInput
                animated
                tickWhileDragging
                value={node1_concentration}
                step={1}
                unit="%"
                width="60px"
                minValue={0}
                maxValue={100}
                stepPixelSize={2}
                onChange={(value) =>
                  act('node1', {
                    concentration: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Side Node" labelColor="blue">
              <NumberInput
                animated
                tickWhileDragging
                value={node2_concentration}
                step={1}
                unit="%"
                width="60px"
                minValue={0}
                maxValue={100}
                stepPixelSize={2}
                onChange={(value) =>
                  act('node2', {
                    concentration: value,
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

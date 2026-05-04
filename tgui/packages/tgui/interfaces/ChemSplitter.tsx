import { LabeledList, NumberInput, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  straight: number;
  left: number;
  right: number;
  max_transfer: number;
};

export const ChemSplitter = (props) => {
  const { act, data } = useBackend<Data>();
  const { straight, left, right, max_transfer } = data;

  return (
    <Window width={270} height={140}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Straight">
              <NumberInput
                value={straight}
                unit="u"
                width="80px"
                minValue={1}
                maxValue={max_transfer}
                format={(value) => toFixed(value, 2)}
                step={0.05}
                stepPixelSize={4}
                onChange={(value) =>
                  act('set_amount', {
                    target: 'straight',
                    amount: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Left">
              <NumberInput
                value={left}
                unit="u"
                width="80px"
                minValue={1}
                maxValue={max_transfer}
                format={(value) => toFixed(value, 2)}
                step={0.05}
                stepPixelSize={4}
                onChange={(value) =>
                  act('set_amount', {
                    target: 'left',
                    amount: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Right">
              <NumberInput
                value={right}
                unit="u"
                width="80px"
                minValue={1}
                maxValue={max_transfer}
                format={(value) => toFixed(value, 2)}
                step={0.05}
                stepPixelSize={4}
                onChange={(value) =>
                  act('set_amount', {
                    target: 'right',
                    amount: value,
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

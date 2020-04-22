import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const AtmosMixer = (props, context) => {
  const { act, data } = useBackend(context);
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
            <LabeledList.Item label="Output Pressure">
              <NumberInput
                animated
                value={parseFloat(data.set_pressure)}
                unit="kPa"
                width="75px"
                minValue={0}
                maxValue={4500}
                step={10}
                onChange={(e, value) => act('pressure', {
                  pressure: value,
                })} />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={data.set_pressure === data.max_pressure}
                onClick={() => act('pressure', {
                  pressure: 'max',
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Node 1">
              <NumberInput
                animated
                value={data.node1_concentration}
                unit="%"
                width="60px"
                minValue={0}
                maxValue={100}
                stepPixelSize={2}
                onDrag={(e, value) => act('node1', {
                  concentration: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Node 2">
              <NumberInput
                animated
                value={data.node2_concentration}
                unit="%"
                width="60px"
                minValue={0}
                maxValue={100}
                stepPixelSize={2}
                onDrag={(e, value) => act('node2', {
                  concentration: value,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

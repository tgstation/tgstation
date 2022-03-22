import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const AtmosPump = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={335}
      height={115}>
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
            {data.max_rate ? (
              <LabeledList.Item label="Transfer Rate">
                <NumberInput
                  animated
                  value={parseFloat(data.rate)}
                  width="63px"
                  unit="L/s"
                  minValue={0}
                  maxValue={data.max_rate}
                  onChange={(e, value) => act('rate', {
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
            ) : (
              <LabeledList.Item label="Output Pressure">
                <NumberInput
                  animated
                  value={parseFloat(data.pressure)}
                  unit="kPa"
                  width="75px"
                  minValue={0}
                  maxValue={data.max_pressure}
                  step={10}
                  onChange={(e, value) => act('pressure', {
                    pressure: value,
                  })} />
                <Button
                  ml={1}
                  icon="plus"
                  content="Max"
                  disabled={data.pressure === data.max_pressure}
                  onClick={() => act('pressure', {
                    pressure: 'max',
                  })} />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

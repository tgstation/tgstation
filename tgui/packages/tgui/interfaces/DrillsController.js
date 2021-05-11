import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Modal, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const DrillsController = (props, context) => {
  const { act, data } = useBackend(context);
  const onlineDrills = data.online_drills || [];

  return (
    <Window
      width={500}
      height={400}>
      <Window.Content scrollable>
        <Button
          content={'Reconnect drills'}
          color={"green"}
          onClick={() => act('reconnect', {})} />
        {onlineDrills.map(drill => (
          <Section title={drill.name+" "+drill.coord+" "+drill.ore_type}>
            <LabeledList>
              <LabeledList.Item label="Controls">
                <Button
                  disabled={!drill.connected}
                  key={drill.drill_id}
                  content={drill.operating ? 'Drill operational' : 'Drill off'}
                  color={drill.operating ? "green" : "red"}
                  onClick={() => act('operating', {
                    drill_id: drill.drill_id,
                  })} />
                <Button
                  disabled={!drill.connected}
                  key={drill.drill_id}
                  content={drill.powered ? 'Power ON' : 'Power OFF'}
                  color={drill.powered ? "green" : "red"}
                  onClick={() => act('power', {
                    drill_id: drill.drill_id,
                  })} />
              </LabeledList.Item>
              <LabeledList.Item label="Ore Extraction Rate">
                <NumberInput
                  disabled={!drill.connected}
                  animated
                  value={drill.extraction_rate}
                  unit="ore/run"
                  width="62px"
                  minValue={0}
                  maxValue={20}
                  step={1}
                  stepPixelSize={1}
                  onDrag={(e, value) => act('rate', {
                    amount: value,
                    drill_id: drill.drill_id,
                  })} />
              </LabeledList.Item>
              <LabeledList.Item label="Remaining Ore Amount">
                <Box m={1} style={{
                  'white-space': 'pre-wrap',
                }}>
                  {drill.ore_amount + " Ores"}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Drill Power Consumption">
                <Box m={1} style={{
                  'white-space': 'pre-wrap',
                }}>
                  {drill.power_consumption * 0.001 + " kW"}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};

import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

export const PortablePump = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    into_pump_or_port,
    source_one,
    source_two,
    target_pressure,
    default_pressure,
    min_pressure,
    max_pressure,
  } = data;
  return (
    <Window
      width={300}
      height={315}>
      <Window.Content>
        <PortableBasicInfo />
        <Section
          title="Pumping"
          buttons={(
            <Button
              content={
                into_pump_or_port
                  ? area_or_tank + ' → ' + pump_or_port
                  : pump_or_port + ' → ' + area_or_tank
              }
              onClick={() => act('direction')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Output">
              <NumberInput
                value={target_pressure}
                unit="kPa"
                width="75px"
                minValue={min_pressure}
                maxValue={max_pressure}
                step={10}
                onChange={(e, value) => act('pressure', {
                  pressure: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Presets">
              <Button
                icon="minus"
                disabled={target_pressure === min_pressure}
                onClick={() => act('pressure', {
                  pressure: 'min',
                })} />
              <Button
                icon="sync"
                disabled={target_pressure === default_pressure}
                onClick={() => act('pressure', {
                  pressure: 'reset',
                })} />
              <Button
                icon="plus"
                disabled={target_pressure === max_pressure}
                onClick={() => act('pressure', {
                  pressure: 'max',
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const ChemAcclimator = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content>
        <Section title="Acclimator">
          <LabeledList>
            <LabeledList.Item label="Current Temperature">
              {data.chem_temp} K
            </LabeledList.Item>
            <LabeledList.Item label="Target Temperature">
              <NumberInput
                value={data.target_temperature}
                unit="K"
                width="59px"
                minValue={0}
                maxValue={1000}
                step={5}
                stepPixelSize={2}
                onChange={(e, value) => act('set_target_temperature', {
                  temperature: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Acceptable Temp. Difference">
              <NumberInput
                value={data.allowed_temperature_difference}
                unit="K"
                width="59px"
                minValue={1}
                maxValue={data.target_temperature}
                stepPixelSize={2}
                onChange={(e, value) => {
                  act('set_allowed_temperature_difference', {
                    temperature: value,
                  });
                }} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Status"
          buttons={(
            <Button
              icon="power-off"
              content={data.enabled ? "On" : "Off"}
              selected={data.enabled}
              onClick={() => act('toggle_power')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Volume">
              <NumberInput
                value={data.max_volume}
                unit="u"
                width="50px"
                minValue={data.reagent_volume}
                maxValue={200}
                step={2}
                stepPixelSize={2}
                onChange={(e, value) => act('change_volume', {
                  volume: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Current Operation">
              {data.acclimate_state}
            </LabeledList.Item>
            <LabeledList.Item label="Current State">
              {data.emptying ? 'Emptying' : 'Filling'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

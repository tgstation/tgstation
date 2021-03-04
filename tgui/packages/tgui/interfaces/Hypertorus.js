import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, ProgressBar, Section, Stack } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { formatSiBaseTenUnit, formatSiUnit } from '../format';
import { Window } from '../layouts';

export const Hypertorus = (props, context) => {
  const { act, data } = useBackend(context);
  const filterTypes = data.filter_types || [];
  const {
    energy_level,
    core_temperature,
    internal_power,
    power_output,
    heat_limiter_modifier,
    heat_output,
    heat_output_bool,
    heating_conductor,
    magnetic_constrictor,
    fuel_injection_rate,
    moderator_injection_rate,
    current_damper,
    power_level,
    iron_content,
    integrity,
    start_power,
    start_cooling,
    start_fuel,
    internal_fusion_temperature,
    moderator_internal_temperature,
    internal_output_temperature,
    internal_coolant_temperature,
    waste_remove,
  } = data;
  const fusion_gases = flow([
    filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.fusion_gases || []);
  const moderator_gases = flow([
    filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.moderator_gases || []);
  const fusionMax = Math.max(1, ...fusion_gases.map(gas => gas.amount));
  const moderatorMax = Math.max(1, ...moderator_gases.map(gas => gas.amount));
  return (
    <Window
      title="Fusion Reactor"
      width={500}
      height={600}>
      <Window.Content scrollable>
        <Section title="Switches">
          <Stack>
            <Stack.Item color="label">
              {'Start power: '}
              <Button
                disabled={data.power_level > 0}
                icon={data.start_power ? 'power-off' : 'times'}
                content={data.start_power ? 'On' : 'Off'}
                selected={data.start_power}
                onClick={() => act('start_power')} />
            </Stack.Item>
            <Stack.Item color="label">
              {'Start cooling: '}
              <Button
                disabled={start_fuel === 1
                  || start_power === 0
                  || (start_cooling && data.power_level > 0)}
                icon={data.start_cooling ? 'power-off' : 'times'}
                content={data.start_cooling ? 'On' : 'Off'}
                selected={data.start_cooling}
                onClick={() => act('start_cooling')} />
            </Stack.Item>
            <Stack.Item color="label">
              {'Start fuel injection: '}
              <Button
                disabled={start_power === 0
                  || start_cooling === 0}
                icon={data.start_fuel ? 'power-off' : 'times'}
                content={data.start_fuel ? 'On' : 'Off'}
                selected={data.start_fuel}
                onClick={() => act('start_fuel')} />
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Internal Fusion Gases">
          <LabeledList>
            {fusion_gases.map(gas => (
              <LabeledList.Item
                key={gas.name}
                label={getGasLabel(gas.name)}>
                <ProgressBar
                  color={getGasColor(gas.name)}
                  value={gas.amount}
                  minValue={0}
                  maxValue={fusionMax}>
                  {toFixed(gas.amount, 2) + ' moles'}
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Moderator Gases">
          <LabeledList>
            {moderator_gases.map(gas => (
              <LabeledList.Item
                key={gas.name}
                label={getGasLabel(gas.name)}>
                <ProgressBar
                  color={getGasColor(gas.name)}
                  value={gas.amount}
                  minValue={0}
                  maxValue={moderatorMax}>
                  {toFixed(gas.amount, 2) + ' moles'}
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Reactor Parameters">
          <LabeledList>
            <LabeledList.Item label="Power Level">
              <ProgressBar
                value={power_level}
                ranges={{
                  good: [0, 2],
                  average: [2, 4],
                  bad: [4, 6],
                }} />
            </LabeledList.Item>
            <LabeledList.Item label="Integrity">
              <ProgressBar
                value={integrity / 100}
                ranges={{
                  good: [0.90, Infinity],
                  average: [0.5, 0.90],
                  bad: [-Infinity, 0.5],
                }} />
            </LabeledList.Item>
            <LabeledList.Item label="Iron Content">
              <ProgressBar
                value={iron_content}
                ranges={{
                  good: [-Infinity, 3],
                  average: [3, 6],
                  bad: [6, Infinity],
                }} />
            </LabeledList.Item>
            <LabeledList.Item label="Energy Levels">
              <ProgressBar
                color={'yellow'}
                value={energy_level}
                minValue={0}
                maxValue={1e35}>
                {formatSiUnit(energy_level, 1, 'J')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Heat Limiter Modifier">
              <ProgressBar
                color={'blue'}
                value={heat_limiter_modifier}
                minValue={-1e40}
                maxValue={1e30}>
                {formatSiBaseTenUnit(heat_limiter_modifier * 1000, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Heat Output">
              <ProgressBar
                color={'grey'}
                value={heat_output}
                minValue={-1e40}
                maxValue={1e30}>
                {heat_output_bool + formatSiBaseTenUnit(heat_output * 1000, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Temperatures">
          <LabeledList>
            <LabeledList.Item label="Fusion gas temperature">
              <ProgressBar
                color={'yellow'}
                value={internal_fusion_temperature}
                minValue={0}
                maxValue={1e30}>
                {formatSiBaseTenUnit(internal_fusion_temperature * 1000, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Moderator gas temperature">
              <ProgressBar
                color={'red'}
                value={moderator_internal_temperature}
                minValue={0}
                maxValue={1e30}>
                {formatSiBaseTenUnit(moderator_internal_temperature * 1000, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Output gas temperature">
              <ProgressBar
                color={'pink'}
                value={internal_output_temperature}
                minValue={0}
                maxValue={1e30}>
                {formatSiBaseTenUnit(internal_output_temperature * 1000, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Coolant output temperature">
              <ProgressBar
                color={'green'}
                value={internal_coolant_temperature}
                minValue={0}
                maxValue={1e30}>
                {formatSiBaseTenUnit(internal_coolant_temperature * 1000, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Tweakable Inputs">
          <LabeledList>
            <LabeledList.Item label="Heating Conductor">
              <NumberInput
                animated
                value={parseFloat(data.heating_conductor)}
                width="63px"
                unit="J/cm"
                minValue={50}
                maxValue={500}
                onDrag={(e, value) => act('heating_conductor', {
                  heating_conductor: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Magnetic Constrictor">
              <NumberInput
                animated
                value={parseFloat(data.magnetic_constrictor)}
                width="63px"
                unit="m^3/B"
                minValue={50}
                maxValue={1000}
                onDrag={(e, value) => act('magnetic_constrictor', {
                  magnetic_constrictor: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Fuel Injection Rate">
              <NumberInput
                animated
                value={parseFloat(data.fuel_injection_rate)}
                width="63px"
                unit="g/s"
                minValue={5}
                maxValue={1500}
                onDrag={(e, value) => act('fuel_injection_rate', {
                  fuel_injection_rate: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Moderator Injection Rate">
              <NumberInput
                animated
                value={parseFloat(data.moderator_injection_rate)}
                width="63px"
                unit="g/s"
                minValue={5}
                maxValue={1500}
                onDrag={(e, value) => act('moderator_injection_rate', {
                  moderator_injection_rate: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Current Damper">
              <NumberInput
                animated
                value={parseFloat(data.current_damper)}
                width="63px"
                unit="W"
                minValue={0}
                maxValue={1000}
                onDrag={(e, value) => act('current_damper', {
                  current_damper: value,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Waste remove">
              <Button
                disabled={data.power_level > 5}
                icon={data.waste_remove ? 'power-off' : 'times'}
                content={data.waste_remove ? 'On' : 'Off'}
                selected={data.waste_remove}
                onClick={() => act('waste_remove')} />
            </LabeledList.Item>
            <LabeledList.Item label="Filter from moderator mix">
              {filterTypes.map(filter => (
                <Button
                  key={filter.id}
                  selected={filter.selected}
                  content={getGasLabel(filter.id, filter.name)}
                  onClick={() => act('filter', {
                    mode: filter.id,
                  })} />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

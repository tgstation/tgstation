import { sortBy, map, filter } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Button, Flex, Input, LabeledList, ProgressBar, Section, Table, NumberInput } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';
import { formatSiUnit, formatSiBaseTenUnit } from '../format';

export const Hypertorus = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    energy_level,
    core_temperature,
    internal_power,
    power_output,
    heat_limiter_modifier,
    heat_output,
    heating_conductor,
    magnetic_constrictor,
    fuel_injection_rate,
    moderator_injection_rate,
    current_damper,
    fusion_started,
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
      width={500}
      height={600}
      scrollable
      resizable>
      <Window.Content>
        <Section title="Fusion Reactor">
          <LabeledList>
            <LabeledList.Item label="Powered">
              <Button
                disabled={data.power_level > 2}
                icon={data.fusion_started ? 'power-off' : 'times'}
                content={data.fusion_started ? 'On' : 'Off'}
                selected={data.fusion_started}
                onClick={() => act('fusion_started')} />
            </LabeledList.Item>
          </LabeledList>
          <Section>
            <Section title="Internal Fusion Gases">
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
            </Section>
            <Section title="Moderator Gases">
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
            </Section>
          </Section>
          <Section title="Reactor Parameters">
            <LabeledList.Item label="Energy Levels">
              <ProgressBar
                color={'yellow'}
                value={energy_level}
                minValue={-1e40}
                maxValue={1e40}>
                {formatSiUnit(energy_level, 1, 'J')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Internal Power">
              <ProgressBar
                color={'orange'}
                value={internal_power}
                minValue={-1e40}
                maxValue={1e30}>
                {formatSiUnit(internal_power, 1, 'J')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Core Temperature">
              <ProgressBar
                color={'red'}
                value={core_temperature}
                minValue={-1e40}
                maxValue={1e30}>
                {formatSiBaseTenUnit(core_temperature, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Power Output">
              <ProgressBar
                color={'green'}
                value={power_output}
                minValue={-1e40}
                maxValue={1e30}>
                {formatSiUnit(power_output, 1, 'J')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Heat Limiter Modifier">
              <ProgressBar
                color={'blue'}
                value={heat_limiter_modifier}
                minValue={-1e40}
                maxValue={1e30}>
                {formatSiBaseTenUnit(heat_limiter_modifier, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Heat Output">
              <ProgressBar
                color={'grey'}
                value={heat_output}
                minValue={-1e40}
                maxValue={1e30}>
                {formatSiBaseTenUnit(heat_output, 1, 'K')}
              </ProgressBar>
            </LabeledList.Item>
          </Section>
          <Section title="Tweakable Inputs">
            <LabeledList.Item label="Heating Conductor">
              <NumberInput
                animated
                value={parseFloat(data.heating_conductor)}
                width="63px"
                unit="J/cm"
                minValue={0.5}
                maxValue={10}
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
                minValue={0.5}
                maxValue={10}
                onDrag={(e, value) => act('magnetic_constrictor', {
                  magnetic_constrictor: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Fuel Injection Rate">
              <NumberInput
                animated
                value={parseFloat(data.fuel_injection_rate)}
                width="63px"
                unit="mol/s"
                minValue={1}
                maxValue={150}
                onDrag={(e, value) => act('fuel_injection_rate', {
                  fuel_injection_rate: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Moderator Injection Rate">
              <NumberInput
                animated
                value={parseFloat(data.moderator_injection_rate)}
                width="63px"
                unit="mol/s"
                minValue={1}
                maxValue={150}
                onDrag={(e, value) => act('moderator_injection_rate', {
                  moderator_injection_rate: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Current Damper">
              <NumberInput
                animated
                value={parseFloat(data.current_damper)}
                width="63px"
                unit="mol/s"
                minValue={0}
                maxValue={5}
                onDrag={(e, value) => act('current_damper', {
                  current_damper: value,
                })} />
            </LabeledList.Item>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};

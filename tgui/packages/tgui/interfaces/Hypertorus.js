import { sortBy, map } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Button, Flex, Input, LabeledList, ProgressBar, Section, Table, NumberInput } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

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
  } = data;
  const fusion_gases = flow([
    fusion_gases => fusion_gases.filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.fusion_gases || []);
  const moderator_gases = flow([
    moderator_gases => moderator_gases.filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.moderator_gases || []);
  const fusionMax = Math.max(1, ...fusion_gases.map(gas => gas.amount));
  const moderatorMax = Math.max(1, ...moderator_gases.map(gas => gas.amount));
  return (
    <Window
      width={500}
      height={500}
      scrollable
      resizable>
      <Window.Content>
        <Flex>
          <Flex.Item grow={1} basis={0}>
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
              <LabeledList.Item label="Energy Levels">
                <ProgressBar
                  value={energy_level}
                  minValue={-1e40}
                  maxValue={1e40}>
                  {formatSiUnit(value, 1, 'K')}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Core Temperature">
                <ProgressBar
                  value={core_temperature}
                  minValue={-1e40}
                  maxValue={1e30}>
                  {formatSiUnit(value, 1, 'K')}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Internal Power">
                <ProgressBar
                  value={internal_power}
                  minValue={-1e40}
                  maxValue={1e30}>
                  {formatSiUnit(value, 1, 'J')}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Power Output">
                <ProgressBar
                  value={power_output}
                  minValue={-1e40}
                  maxValue={1e30}>
                  {formatSiUnit(value, 1, 'J')}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Heat Limiter Modifier">
                <ProgressBar
                  value={heat_limiter_modifier}
                  minValue={-1e40}
                  maxValue={1e30}>
                  {formatSiUnit(value, 1, 'K')}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Heat Output">
                <ProgressBar
                  value={heat_output}
                  minValue={-1e40}
                  maxValue={1e30}>
                  {formatSiUnit(value, 1, 'K')}
                </ProgressBar>
              </LabeledList.Item>
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
                  unit="m^3/B"
                  minValue={0}
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
                  unit="m^3/B"
                  minValue={0}
                  maxValue={150}
                  onDrag={(e, value) => act('moderator_injection_rate', {
                    moderator_injection_rate: value,
                  })} />
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

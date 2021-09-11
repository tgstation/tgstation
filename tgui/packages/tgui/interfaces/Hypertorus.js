import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, Icon, Knob, LabeledControls, LabeledList, NumberInput, ProgressBar, RoundGauge, Section, Stack, Table, Tabs, Tooltip } from '../components';
import { Color } from '../../common/color';
import { getGasColor, getGasLabel } from '../constants';
import { recallWindowGeometry } from '../drag';
import { formatSiBaseTenUnit, formatSiUnit } from '../format';
import { Window } from '../layouts';

/**
 * The list of recipe effects to list, in order.
 * Parameters:
 *  - param: The name of the parameter passed in the data object.
 *  - label: The human readable label for this effect.
 *  - scale: The point at which a directional arrow become a
 *           double directional arrow.
 *  - icon:  A string or array of strings describing a pictographic
 *           icon for use with this effect.
 *  - override_base: Optional. Sets the base value for scale calculations
 *                   to something other than 1.
 *  - tooltip: Optional.
 *             If specified, this is passed the value and full data
 *             array and should return the tooltip string.
 *             If omitted, the default of "x{value}" is used.
 *
 */
const recipe_effect_structure = [
  {
    param: "recipe_cooling_multiplier",
    label: "Cooling",
    icon: "snowflake-o",
    scale: 3,
  },
  {
    param: "recipe_heating_multiplier",
    label: "Heating",
    icon: "fire",
    scale: 3,
  },
  {
    param: "energy_loss_multiplier",
    label: "Energy loss",
    icon: "sun-o",
    scale: 3,
  },
  {
    param: "fuel_consumption_multiplier",
    label: "Fuel use",
    icon: ["window-minimize", "arrow-down"],
    scale: 1.5,
  },
  {
    param: "gas_production_multiplier",
    label: "Production",
    icon: ["window-minimize", "arrow-up"],
    scale: 1.5,
  },
  {
    param: "temperature_multiplier",
    label: "Max temperature",
    icon: "thermometer-full",
    override_base: 0.85,
    scale: 1.15,
    tooltip: (v, d) => "Maximum: " + (d.base_max_temperature * v).toExponential() + " K",
  },
];

const effect_to_icon = (effect_value, effect_scale, base) => {
  if (effect_value === base) {
    return "minus";
  }
  if (effect_value > base) {
    if (effect_value > base * effect_scale) {
      return "angle-double-up";
    }
    return "angle-up";
  }
  if (effect_value < base / effect_scale) {
    return "angle-double-down";
  }
  return "angle-down";
};

const bgChange = {
  onComponentShouldUpdate: (lastProps, nextProps) => {
    return lastProps.backgroundColor !== nextProps.backgroundColor;
  },
};

const MemoRow = props => {
  const {
    backgroundColor,
    children,
    key,
    ...rest
  } = props;
  return <Table.Row backgroundColor={backgroundColor} {...rest}>{children}</Table.Row>
};

MemoRow.defaultHooks = bgChange;

const GasCellItem = props => {
  const {
    gasid,
    ...rest
  } = props;
  return (
    <Table.Cell
      key={gasid}
      label={getGasLabel(gasid)} {...rest}>
      <Box color={getGasColor(gasid)}>{getGasLabel(gasid)}</Box>
    </Table.Cell>
  );
};

// Quick wrapper to globally toggle use of tooltips on or off.
// Remove once tooltip performance is fixed for good.
const MaybeTooltip = props => {
  const {
    children,
    ...rest
  } = props;
  const noTooltips = true;
  if (noTooltips) {
    return (<Box>{children}</Box>);
  }
  return (<Tooltip {...rest}>{children}</Tooltip>);
};

const ActParam = (key,value) => {
  const ret = {};
  ret[key] = value;
  return ret;
};

const TweakControl = props => {
  const {
    act,
    minValue,
    maxValue,
    parameter,
    step=5,
    unit,
    value,
    ...rest
  } = props;
  return (<Box
    position="relative"
    left="-8px">
    <Knob
      size={2}
      color={false}
      value={value}
      unit={unit}
      minValue={minValue}
      maxValue={maxValue}
      step={step}
      stepPixelSize={1}
      onDrag={(e, value) => act(parameter, ActParam(parameter, value))}
    />
    <Button
      fluid
      position="absolute"
      top="-2px"
      right="-20px"
      color="transparent"
      icon="fast-forward"
      onClick={() => act(parameter, ActParam(parameter, maxValue))}
    />
    <Button
      fluid
      position="absolute"
      top="16px"
      right="-20px"
      color="transparent"
      icon="fast-backward"
      onClick={() => act(parameter, ActParam(parameter, minValue))}
    />
  </Box>);
}

const HypertorusMainControls = (props, context) => {
  const { act, data } = useBackend(context);
  const selectableFuels = data.selectable_fuel || [];
  const selectedFuel = selectableFuels.filter(d => d.id === data.selected)[0];
  return (
    <Section title="Startup">
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
            disabled={data.start_fuel === 1
                || data.start_moderator === 1
                || data.start_power === 0
                || (data.start_cooling && data.power_level > 0)}
            icon={data.start_cooling ? 'power-off' : 'times'}
            content={data.start_cooling ? 'On' : 'Off'}
            selected={data.start_cooling}
            onClick={() => act('start_cooling')} />
        </Stack.Item>
        <Stack.Item color="label">
          {'Start fuel injection: '}
          <Button
            disabled={data.start_power === 0
                || data.start_cooling === 0}
            icon={data.start_fuel ? 'power-off' : 'times'}
            content={data.start_fuel ? 'On' : 'Off'}
            selected={data.start_fuel}
            onClick={() => act('start_fuel')} />
        </Stack.Item>
        <Stack.Item color="label">
          {'Start moderator injection: '}
          <Button
            disabled={data.start_power === 0
                || data.start_cooling === 0}
            icon={data.start_moderator ? 'power-off' : 'times'}
            content={data.start_moderator ? 'On' : 'Off'}
            selected={data.start_moderator}
            onClick={() => act('start_moderator')} />
        </Stack.Item>
      </Stack>
      <Collapsible title="Recipe selection">
        <Table>
          <MemoRow color="label" header>
            <Table.Cell />
            <Table.Cell textAlign="center" colspan="2">
              Fuel
            </Table.Cell>
            <Table.Cell textAlign="center" colspan="2">
              Fusion Byproducts
            </Table.Cell>
            <Table.Cell textAlign="center" colspan="6">
              Produced gases
            </Table.Cell>
            <Table.Cell textAlign="center" colspan="6">
              Effects
            </Table.Cell>
            <Table.Cell grow="1" />
          </MemoRow>
          <MemoRow color="label" header>
            <Table.Cell />
            <Table.Cell textAlign="center">
              Primary
            </Table.Cell>
            <Table.Cell textAlign="center">
              Secondary
            </Table.Cell>
            <Table.Cell colspan="2"/>
            <Table.Cell textAlign="center">
              Tier 1
            </Table.Cell>
            <Table.Cell textAlign="center">
              Tier 2
            </Table.Cell>
            <Table.Cell textAlign="center">
              Tier 3
            </Table.Cell>
            <Table.Cell textAlign="center">
              Tier 4
            </Table.Cell>
            <Table.Cell textAlign="center">
              Tier 5
            </Table.Cell>
            <Table.Cell textAlign="center">
              Tier 6
            </Table.Cell>
            {
              // Lay out our pictographic headers for effects.
              recipe_effect_structure.map(item => (
                <Table.Cell key={item.param} color="label">
                <MaybeTooltip content={item.label}>
                  {typeof(item.icon) === "string" ? (
                    <Icon position="relative" width="10px" name={item.icon} />
                  ) : (
                    <Icon.Stack positition="relative" width="10px" textAlign="center">
                      {item.icon.map(icon => (
                        <Icon name={typeof(icon) === "string" ? icon : "shit's fucked"} />
                      ))}
                    </Icon.Stack>
                  )}
                </MaybeTooltip>
                </Table.Cell>
              ))
            }
          </MemoRow>
          {selectableFuels.filter(d=>d.id).map((recipe,index) => {
            const active = recipe.id === data.selected;
            const odd = 1 - 2 * (index % 2);
            const secondary = 50 - odd * 50;
            const primary = active ? secondary + 80 : secondary;
            const alpha = (active ? .13 : .07);
            return (
              <MemoRow backgroundColor={new Color(secondary, primary, secondary, alpha)}>
                <Table.Cell>
                  <Button
                    icon={recipe.id === data.selected ? "times" : "power-off"}
                    disabled={data.power_level > 0}
                    key={recipe.id}
                    selected={recipe.id === data.selected}
                    onClick={() => act('fuel', {mode: recipe.id})}
                  />
                </Table.Cell>
                <GasCellItem gasid={recipe.requirements[0]} />
                <GasCellItem gasid={recipe.requirements[1]} />
                <GasCellItem gasid={recipe.fusion_byproducts[0]} />
                <GasCellItem gasid={recipe.fusion_byproducts[1]} />
                {recipe.product_gases.map(gasid => (
                  <GasCellItem gasid={gasid} />
                ))}
                {
                  recipe_effect_structure.map(item => {
                    const value = recipe[item.param];
                    // Note that the minus icon is wider than the arrow icons,
                    // so we set the width to work with both without jumping.
                    return (
                      <Table.Cell>
                        <MaybeTooltip content={(item.tooltip || (v => "x"+v))(value, data)}>
                          <Icon position="relative" color="rgb(230,30,40)" width="10px" name={effect_to_icon(value, item.scale, item.override_base || 1)} />
                        </MaybeTooltip>
                      </Table.Cell>
                    );
                  })
                }
              </MemoRow>
            );
          })}
        </Table>
      </Collapsible>
    </Section>
  );
};

const HypertorusSecondaryControls = (props, context) => {
  const { act, data } = useBackend(context);
  const filterTypes = data.filter_types || [];
  return (
    <>
      <Section title="Tweakable Inputs">
        <LabeledControls>
          <LabeledControls.Item label="Heating Conductor">
            <TweakControl
              act={act}
              value={parseFloat(data.heating_conductor)}
              unit="J/cm"
              minValue={50}
              maxValue={500}
              parameter='heating_conductor'
            />
          </LabeledControls.Item>
          <LabeledControls.Item label="Cooling Volume">
            <TweakControl
              act={act}
              value={parseFloat(data.cooling_volume)}
              unit="L"
              minValue={50}
              maxValue={2000}
              parameter='cooling_volume'
              step={25}
            />
          </LabeledControls.Item>
          <LabeledControls.Item label="Magnetic Constrictor">
            <TweakControl
              act={act}
              value={parseFloat(data.magnetic_constrictor)}
              unit="m³/T"
              minValue={50}
              maxValue={1000}
              parameter='magnetic_constrictor'
            />
          </LabeledControls.Item>
          <LabeledControls.Item label="Current Damper">
            <TweakControl
              act={act}
              value={parseFloat(data.current_damper)}
              unit="W"
              minValue={0}
              maxValue={1000}
              onDrag={(e, value) => act('current_damper', {
                current_damper: value,
              })} />
          </LabeledControls.Item>
        </LabeledControls>
      </Section>
      <Section>
        <LabeledControls>
          <LabeledControls.Item label="Fuel Injection Rate">
            <NumberInput
              animated
              value={parseFloat(data.fuel_injection_rate)}
              unit="mol/s"
              minValue={.5}
              maxValue={150}
              onDrag={(e, value) => act('fuel_injection_rate', {
                fuel_injection_rate: value,
              })} />
          </LabeledControls.Item>
          <LabeledControls.Item label="Moderator Injection Rate">
            <NumberInput
              animated
              value={parseFloat(data.moderator_injection_rate)}
              unit="mol/s"
              minValue={.5}
              maxValue={150}
              onDrag={(e, value) => act('moderator_injection_rate', {
                moderator_injection_rate: value,
              })} />
          </LabeledControls.Item>
          <LabeledControls.Item label="Moderator filtering rate">
            <NumberInput
              animated
              value={parseFloat(data.mod_filtering_rate)}
              unit="mol/s"
              minValue={5}
              maxValue={200}
              onDrag={(e, value) => act('mod_filtering_rate', {
                mod_filtering_rate: value,
              })} />
          </LabeledControls.Item>
        </LabeledControls>
      </Section>
      <Section title="Waste control and filtering">
        <LabeledList>
          <LabeledList.Item label="Waste remove">
            <Button
              icon={data.waste_remove ? 'power-off' : 'times'}
              content={data.waste_remove ? 'On' : 'Off'}
              selected={data.waste_remove}
              onClick={() => act('waste_remove')} />
          </LabeledList.Item>
          <LabeledList.Item label="Filter from moderator mix">
            {filterTypes.map(filter => (
              <Button
                key={filter.gas_id}
                icon={filter.enabled ? 'check-square-o' : 'square-o'}
                selected={filter.enabled}
                content={getGasLabel(filter.gas_id, filter.gas_name)}
                onClick={() => act('filter', {
                  mode: filter.gas_id,
                })} />
            ))}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};

const HypertorusGases = (props, context) => {
  const { act, data } = useBackend(context);
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
    <>
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
    </>
  );
};

const HypertorusParameters = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    energy_level,
    heat_limiter_modifier,
    heat_output,
    heat_output_bool,
    power_level,
    iron_content,
    integrity,
    internal_fusion_temperature,
    moderator_internal_temperature,
    internal_output_temperature,
    internal_coolant_temperature,
  } = data;
  return (
    <>
      <Section title="Reactor Parameters">
        <LabeledControls>
          <LabeledControls.Item label="Fusion Level">
            <RoundGauge
              size={1.75}
              minValue={0}
              maxValue={6}
              value={power_level}
              alertAfter={5}
              ranges={{
                good: [0, 2],
                average: [2, 4],
                bad: [4, 6],
              }} />
          </LabeledControls.Item>
          <LabeledControls.Item label="Integrity">
            <ProgressBar
              value={integrity / 100}
              ranges={{
                good: [0.90, Infinity],
                average: [0.5, 0.90],
                bad: [-Infinity, 0.5],
              }} />
          </LabeledControls.Item>
          <LabeledControls.Item label="Iron Content">
            <ProgressBar
              value={iron_content}
              ranges={{
                good: [-Infinity, .1],
                average: [.1, .36],
                bad: [.36, Infinity],
              }} />
          </LabeledControls.Item>
          <LabeledControls.Item label="Energy Levels">
            <ProgressBar
              color={'yellow'}
              value={energy_level}
              minValue={0}
              maxValue={1e35}>
              {formatSiUnit(energy_level, 1, 'J')}
            </ProgressBar>
          </LabeledControls.Item>
          <LabeledControls.Item label="Heat Limiter Modifier">
            <ProgressBar
              color={'blue'}
              value={heat_limiter_modifier}
              minValue={-1e40}
              maxValue={1e30}>
              {formatSiBaseTenUnit(heat_limiter_modifier * 1000, 1, 'K')}
            </ProgressBar>
          </LabeledControls.Item>
          <LabeledControls.Item label="Heat Output">
            <ProgressBar
              color={'grey'}
              value={heat_output}
              minValue={-1e40}
              maxValue={1e30}>
              {heat_output_bool + formatSiBaseTenUnit(heat_output * 1000, 1, 'K')}
            </ProgressBar>
          </LabeledControls.Item>
        </LabeledControls>
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
    </>
  );
};

const HypertorusTabs = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 1);
  return (
    <>
      <HypertorusMainControls />
      <HypertorusGases />
      <HypertorusParameters />
      <HypertorusSecondaryControls />
    </>
  );
};


export const Hypertorus = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Hypertorus Fusion Reactor control panel"
      width={950}
      height={600}>
      <Window.Content scrollable>
        <HypertorusTabs />
      </Window.Content>
    </Window>
  );
};

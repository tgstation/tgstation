import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Cell, Collapsible, Flex, Icon, LabeledList, NumberInput, ProgressBar, Row, Section, Stack, Table, Tabs, Tooltip } from '../components';
import { getGasColor, getGasLabel } from '../constants';
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
    label: "Intake",
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
    scale: 1.15,
    tooltip: (v, d) => "Maximum: " + (d.base_max_temperature * v).toExponential() + " K",
  },
];

const effect_to_icon = (effect_value, effect_scale) => {
  if (effect_value === 1) {
    return "minus";
  }
  if (effect_value > 1) {
    if (effect_value > effect_scale) {
      return "angle-double-up";
    }
    return "angle-up";
  }
  if (effect_value < 1 / effect_scale) {
    return "angle-double-down";
  }
  return "angle-down";
};

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

const HypertorusMainControls = (props, context) => {
  const { act, data } = useBackend(context);
  const selectableFuels = data.selectable_fuel || [];
  const selectedFuel = selectableFuels.filter(d => d.id === data.selected)[0];
  return (
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
      <Collapsible title="Fuel selection">
        <Table>
          <Table.Row color="label" header>
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
          </Table.Row>
          <Table.Row color="label" header>
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
          </Table.Row>
          {selectableFuels.filter(d=>d.id).map((recipe,index) => {
            const active = recipe.id === data.selected;
            return (
          <Table.Row backgroundColor={(active ? "rgba(200,255,200," : "rgba(255,255,255,") + ((active ? .13 : 0) + index % 2 * .05) + ")"}>
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
                      <Icon position="relative" color="rgb(230,30,40)" width="10px" name={effect_to_icon(value, item.scale)} />
                    </MaybeTooltip>
                  </Table.Cell>
                );
              })
            }
          </Table.Row>
          );})}
          {false && selectedFuel && (
            <Row label="Production">
              <Stack>
                {selectedFuel.product_gases.map(gasid => (
                  <Stack.Item
                    key={gasid}
                    label={getGasLabel(gasid)}>
                    <Box color={getGasColor(gasid)}>{getGasLabel(gasid)}</Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Row>
          )}
          {false && selectedFuel && (
            <Row label="Effects">
            
            </Row>
          )}
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
          <LabeledList.Item label="Cooling Volume">
            <NumberInput
              animated
              value={parseFloat(data.cooling_volume)}
              width="63px"
              unit="L"
              minValue={50}
              maxValue={2000}
              onDrag={(e, value) => act('cooling_volume', {
                cooling_volume: value,
              })} />
          </LabeledList.Item>
          <LabeledList.Item label="Magnetic Constrictor">
            <NumberInput
              animated
              value={parseFloat(data.magnetic_constrictor)}
              width="63px"
              unit="m³/T"
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
              unit="mol/s"
              minValue={.5}
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
              minValue={.5}
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
              unit="W"
              minValue={0}
              maxValue={1000}
              onDrag={(e, value) => act('current_damper', {
                current_damper: value,
              })} />
          </LabeledList.Item>
        </LabeledList>
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
          <LabeledList.Item label="Moderator filtering rate">
            <NumberInput
              animated
              value={parseFloat(data.mod_filtering_rate)}
              width="63px"
              unit="mol/s"
              minValue={5}
              maxValue={200}
              onDrag={(e, value) => act('mod_filtering_rate', {
                mod_filtering_rate: value,
              })} />
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
                good: [-Infinity, .1],
                average: [.1, .36],
                bad: [.36, Infinity],
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
      <Tabs>
        <Tabs.Tab
          selected={tabIndex === 1}
          onClick={() => {
            setTabIndex(1);
          }}>
          HFR Main controls
        </Tabs.Tab>
        <Tabs.Tab
          selected={tabIndex === 2}
          onClick={() => {
            setTabIndex(2);
          }}>
          HFR Secondary controls
        </Tabs.Tab>
        <Tabs.Tab
          selected={tabIndex === 3}
          onClick={() => {
            setTabIndex(3);
          }}>
          HFR internal gases
        </Tabs.Tab>
        <Tabs.Tab
          selected={tabIndex === 4}
          onClick={() => {
            setTabIndex(4);
          }}>
          HFR internal parameters
        </Tabs.Tab>
      </Tabs>
      {tabIndex === 1 && (
        <HypertorusMainControls />
      )}
      {tabIndex === 2 && (
        <HypertorusSecondaryControls />
      )}
      {tabIndex === 3 && (
        <HypertorusGases />
      )}
      {tabIndex === 4 && (
        <HypertorusParameters />
      )}
    </>
  );
};


export const Hypertorus = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Hypertorus Fusion Reactor control panel"
      width={920}
      height={600}>
      <Window.Content scrollable>
        <HypertorusTabs />
      </Window.Content>
    </Window>
  );
};

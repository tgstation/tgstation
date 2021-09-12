
import { useBackend } from '../backend';
import { Button, Collapsible, Section, Stack } from '../components';
import { Window } from '../layouts';

import { HypertorusGases } from './Hypertorus/Gases';
import { HypertorusParameters } from './Hypertorus/Parameters';
import { HypertorusTemperatures } from './Hypertorus/Temperatures';
import { HypertorusRecipes } from './Hypertorus/Recipes';

import { HypertorusSecondaryControls, HypertorusIO, HypertorusWasteRemove } from './Hypertorus/Controls';

const HypertorusMainControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selectableFuels,
    selectedFuelID,
  } = props;

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
            onClick={act.bind(null, 'start_power')} />
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
            onClick={act.bind(null, 'start_cooling')} />
        </Stack.Item>
        <Stack.Item color="label">
          {'Start fuel injection: '}
          <Button
            disabled={data.start_power === 0
                || data.start_cooling === 0}
            icon={data.start_fuel ? 'power-off' : 'times'}
            content={data.start_fuel ? 'On' : 'Off'}
            selected={data.start_fuel}
            onClick={act.bind(null, 'start_fuel')} />
        </Stack.Item>
        <Stack.Item color="label">
          {'Start moderator injection: '}
          <Button
            disabled={data.start_power === 0
                || data.start_cooling === 0}
            icon={data.start_moderator ? 'power-off' : 'times'}
            content={data.start_moderator ? 'On' : 'Off'}
            selected={data.start_moderator}
            onClick={act.bind(null, 'start_moderator')} />
        </Stack.Item>
      </Stack>
      <Collapsible title="Recipe selection">
        <HypertorusRecipes
          baseMaximumTemperature={data.base_max_temperature}
          enableRecipeSelection={data.power_level === 0}
          onRecipe={id => act('fuel', { mode: id })}
          selectableFuels={selectableFuels}
          selectedFuelID={selectedFuelID}
        />
      </Collapsible>
    </Section>
  );
};

const HypertorusLayout = (props, context) => {
  const { data } = useBackend(context);
  const {
    base_max_temperature,
    energy_level,
    fusion_gases,
    heat_limiter_modifier,
    heat_output,
    heat_output_bool,
    iron_content,
    integrity,
    internal_fusion_temperature,
    internal_output_temperature,
    internal_coolant_temperature,
    moderator_gases,
    moderator_internal_temperature,
    power_level,
    selectable_fuel,
    selected,
  } = data;

  const selectable_fuels = selectable_fuel || [];
  const selected_fuel = selectable_fuels.filter(d => d.id === selected)[0];

  // heat_output_bool is set to '-' if heat_output is negative.
  // heat_output is always the absolute value of heat output.
  // Why? aaaaaaaaaaaaaaaaaaaa
  const real_heat_output = heat_output_bool === '-' ? -heat_output : heat_output;
  const real_heat_limiter_modifier = heat_output_bool === '-' ? -heat_limiter_modifier / 100 : heat_limiter_modifier;

  // Note this adds bottom margin to non-Section elements for consistent
  // spacing. This is a good candidate to be moved to css > properties to
  // avoid low level presentation detail being exposed here.

  return (
    <>
      <HypertorusMainControls
        selectableFuels={selectable_fuels}
        selectedFuelID={selected}
       />
      <Stack mb="0.5em">
        <Stack.Item grow>
          <HypertorusGases
            selectedFuel={selected_fuel}
            fusionGases={fusion_gases}
            moderatorGases={moderator_gases}
            />
        </Stack.Item>
        <Stack.Item>
          <HypertorusTemperatures
            powerLevel={power_level}
            heatOutput={heat_output}
            baseMaxTemperature={base_max_temperature}
            heatLimiterModifier={heat_limiter_modifier}
            internalFusionTemperature={internal_fusion_temperature}
            moderatorInternalTemperature={moderator_internal_temperature}
            internalOutputTemperature={internal_output_temperature}
            internalCoolantTemperature={internal_coolant_temperature}
            selectedFuel={selected_fuel}
          />
        </Stack.Item>
      </Stack>
      <Stack mb="0.5em">
        <Stack.Item>
          <HypertorusParameters
            energyLevel={energy_level}
            rawHeatLimiterModifier={heat_limiter_modifier}
            realHeatOutput={real_heat_output}
            realHeatLimiterModifier={real_heat_limiter_modifier}
            heatOutput={heat_output}
            powerLevel={power_level}
            ironContent={iron_content}
            integrity={integrity}/>
          <HypertorusSecondaryControls />
        </Stack.Item>
        <Stack.Item grow>
          <HypertorusIO />
        </Stack.Item>
      </Stack>
      <HypertorusWasteRemove />
    </>
  );
};

export const Hypertorus = (props, context) => {
  return (
    <Window
      title="Hypertorus Fusion Reactor control panel"
      width={950}
      height={740}>
      <Window.Content scrollable>
        <HypertorusLayout />
      </Window.Content>
    </Window>
  );
};


import { useBackend } from 'tgui/backend';
import { Button, Collapsible, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { HypertorusGases } from './Gases';
import { HypertorusParameters } from './Parameters';
import { HypertorusTemperatures } from './Temperatures';
import { HypertorusRecipes } from './Recipes';

import { ActFixed } from './helpers';
import { HypertorusSecondaryControls, HypertorusWasteRemove } from './Controls';

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
    apc_energy,
    base_max_temperature,
    energy_level,
    fusion_gases,
    heat_limiter_modifier,
    heat_output_min,
    heat_output_max,
    heat_output,
    iron_content,
    instability,
    integrity,
    internal_fusion_temperature,
    internal_fusion_temperature_archived,
    internal_output_temperature,
    internal_output_temperature_archived,
    internal_coolant_temperature,
    internal_coolant_temperature_archived,
    moderator_gases,
    moderator_internal_temperature,
    moderator_internal_temperature_archived,
    power_level,
    selectable_fuel,
    selected,
  } = data;

  const internal_fusion_temperature_delta = internal_fusion_temperature
    - internal_fusion_temperature_archived;
  const internal_output_temperature_delta = internal_output_temperature
    - internal_output_temperature_archived;
  const internal_coolant_temperature_delta = internal_coolant_temperature
    - internal_coolant_temperature_archived;
  const moderator_internal_delta = moderator_internal_temperature
    - moderator_internal_temperature_archived;

  const selectable_fuels = selectable_fuel || [];
  const selected_fuel = selectable_fuels.filter(d => d.id === selected)[0];

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
            baseMaxTemperature={base_max_temperature}
            internalFusionTemperature={internal_fusion_temperature}
            internalFusionTemperatureDelta={internal_fusion_temperature_delta}
            moderatorInternalTemperature={moderator_internal_temperature}
            moderatorInternalTemperatureDelta={moderator_internal_delta}
            internalOutputTemperature={internal_output_temperature}
            internalOutputTemperatureDelta={internal_output_temperature_delta}
            internalCoolantTemperature={internal_coolant_temperature}
            internalCoolantTemperatureDelta={internal_coolant_temperature_delta}
            selectedFuel={selected_fuel}
          />
        </Stack.Item>
      </Stack>
      <HypertorusParameters
        energyLevel={energy_level}
        heatLimiterModifier={heat_limiter_modifier}
        heatOutputMin={heat_output_min}
        heatOutputMax={heat_output_max}
        heatOutput={heat_output}
        apcEnergy={apc_energy}
        instability={instability}
        powerLevel={power_level}
        ironContent={iron_content}
        integrity={integrity} />
      <HypertorusSecondaryControls />
      <HypertorusWasteRemove />
    </>
  );
};

export const Hypertorus = (props, context) => {
  return (
    <Window
      title="Hypertorus Fusion Reactor control panel"
      width={850}
      height={980}>
      <Window.Content scrollable>
        <HypertorusLayout />
      </Window.Content>
    </Window>
  );
};

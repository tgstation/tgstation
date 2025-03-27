import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Icon,
  Knob,
  LabeledControls,
  LabeledList,
  NumberInput,
  Section,
  Tooltip,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { HypertorusFilter } from '.';
import { HelpDummy, HoverHelp } from './helpers';

type ComboProps = {
  color?: string | BooleanLike;
  defaultValue: number;
  flipIcon?: BooleanLike;
  help?: string;
  icon?: string;
  maxValue: number;
  minValue: number;
  parameter: string;
  step?: number;
  unit: string;
  value: number;
};

type ControlsData = {
  cooling_volume: number;
  current_damper: number;
  heat_output: number;
  heating_conductor: number;
  magnetic_constrictor: number;
};

type WasteData = {
  filter_types: HypertorusFilter[];
  mod_filtering_rate: number;
  waste_remove: BooleanLike;
};

/*
 * This module holds user interactable controls. Some may be good candidates
 * for generalizing and refactoring.
 */
const ComboKnob = (props: ComboProps) => {
  const {
    color = false,
    defaultValue,
    flipIcon,
    help,
    icon,
    maxValue,
    minValue,
    parameter,
    step = 5,
    value,
    ...rest
  } = props;

  const { act } = useBackend();

  const iconProps = {
    rotation: 0,
  };
  if (flipIcon) {
    iconProps.rotation = 180;
  }

  const icon_element = icon && (
    <Icon
      position="absolute"
      top="16px"
      left="-27px"
      color="label"
      fontSize="200%"
      name={icon}
      {...iconProps}
    />
  );

  return (
    <Box position="relative" left="2px">
      {help ? <Tooltip content={help}>{icon_element}</Tooltip> : icon_element}
      <Knob
        color={color}
        size={2}
        value={value}
        minValue={minValue}
        maxValue={maxValue}
        step={step}
        stepPixelSize={1}
        onDrag={(_, v) => act(parameter, { [parameter]: v })}
        {...rest}
      />
      <Button
        fluid
        position="absolute"
        top="-2px"
        right="-20px"
        color="transparent"
        icon="fast-forward"
        onClick={() => act(parameter, { [parameter]: maxValue })}
      />
      <Button
        fluid
        position="absolute"
        top="16px"
        right="-20px"
        color="transparent"
        icon="undo"
        onClick={() => act(parameter, { [parameter]: defaultValue })}
      />
      <Button
        fluid
        position="absolute"
        top="34px"
        right="-20px"
        color="transparent"
        icon="fast-backward"
        onClick={() => act(parameter, { [parameter]: minValue })}
      />
    </Box>
  );
};

export const HypertorusSecondaryControls = (props) => {
  const { data } = useBackend<ControlsData>();
  const {
    cooling_volume,
    current_damper,
    heat_output,
    heating_conductor,
    magnetic_constrictor,
  } = data;

  return (
    <Section title="Reactor Control">
      <LabeledControls justify="space-around" wrap>
        <LabeledControls.Item label="Heating Conductor">
          <ComboKnob
            color={heating_conductor > 50 && heat_output > 0 && 'yellow'}
            value={heating_conductor}
            unit="J/cm"
            minValue={50}
            defaultValue={100}
            maxValue={500}
            parameter="heating_conductor"
            icon="fire"
            help="Adjusts the rate the fusion reaction heats or cools. Higher heating values improve production at the risk of a runaway reaction."
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Cooling Volume">
          <ComboKnob
            value={cooling_volume}
            unit="L"
            minValue={50}
            defaultValue={100}
            maxValue={2000}
            parameter="cooling_volume"
            step={25}
            icon="snowflake-o"
            help="Adjusts the HFR core's internal cooling space. A smaller space will provide less cooling internally, but will move most of the coolant outside of the HFR core, where it can be rapidly cooled when not needed."
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Magnetic Constrictor">
          <ComboKnob
            value={magnetic_constrictor}
            unit="m³/T"
            minValue={50}
            defaultValue={100}
            maxValue={1000}
            parameter="magnetic_constrictor"
            icon="magnet"
            flipIcon
            help="Adjusts the density of the fusion reaction. Denser reactions expose more energy, but may destabilize the reaction if too much mass is involved."
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Current Damper">
          <ComboKnob
            color={current_damper && 'yellow'}
            value={current_damper}
            unit="W"
            minValue={0}
            defaultValue={0}
            maxValue={1000}
            parameter="current_damper"
            icon="sun-o"
            help="Destabilizes the reaction. A sufficiently destabilized reaction will halt production and become endothermic, cooling the Fusion Mix instead of heating it. Reactions with more iron are harder to destabilize."
          />
        </LabeledControls.Item>
      </LabeledControls>
    </Section>
  );
};

export const HypertorusWasteRemove = (props) => {
  const { act, data } = useBackend<WasteData>();
  const { filter_types = [], waste_remove, mod_filtering_rate } = data;

  return (
    <Section title="Output Control">
      <LabeledList>
        <LabeledList.Item
          label={
            <>
              <HoverHelp
                content={
                  'Remove waste gases from Fusion,' +
                  ' and any selected gases from the Moderator.'
                }
              />
              Waste remove:
            </>
          }
        >
          <Button
            icon={waste_remove ? 'power-off' : 'times'}
            content={waste_remove ? 'On' : 'Off'}
            selected={waste_remove}
            onClick={() => act('waste_remove')}
          />
        </LabeledList.Item>
        <LabeledList.Item
          label={
            <>
              <HelpDummy />
              Moderator filtering rate:
            </>
          }
        >
          <NumberInput
            animated
            value={mod_filtering_rate}
            unit="mol/s"
            step={1}
            minValue={5}
            maxValue={200}
            onDrag={(value) =>
              act('mod_filtering_rate', {
                mod_filtering_rate: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item
          label={
            <>
              <HelpDummy />
              Filter from moderator mix:
            </>
          }
        >
          {filter_types.map(({ gas_id, gas_name, enabled }) => (
            <Button.Checkbox
              key={gas_id}
              checked={enabled}
              onClick={() =>
                act('filter', {
                  mode: gas_id,
                })
              }
            >
              {gas_name}
            </Button.Checkbox>
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

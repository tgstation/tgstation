
import { useBackend } from '../../backend';
import { Box, Button, Icon, Knob, LabeledControls, LabeledList, NumberInput, Section, Tooltip } from '../../components';
import { getGasLabel } from '../../constants';

/*
 * This module holds user interactable controls. Some may be good candidates
 * for generalizing and refactoring.
 */

const ActParam = (key,value) => {
  const ret = {};
  ret[key] = value;
  return ret;
};

const ComboKnob = props => {
  const {
    act,
    color=false,
    defaultValue,
    icon,
    flipIcon,
    help,
    minValue,
    maxValue,
    parameter,
    step=5,
    value,
    ...rest
  } = props;
  const iconProps = {};
  if (flipIcon) {
    iconProps.rotation = 180;
  }
  const icon_element = icon && (<Icon
    position="absolute"
    top="16px"
    left="-27px"
    color='label'
    fontSize='200%'
    name={icon}
    {...iconProps}
  />);
  return (<Box
    position="relative"
    left="2px">
    {help ?
      (<Tooltip content={help}>{icon_element}</Tooltip>) :
      icon_element
    }
    <Knob
      color={color}
      size={2}
      value={value}
      minValue={minValue}
      maxValue={maxValue}
      step={step}
      stepPixelSize={1}
      onDrag={(e, value) => act(parameter, ActParam(parameter, value))}
      {...rest}
    />
    <Button
      fluid
      position="absolute"
      top="-2px"
      right="-20px"
      color="transparent"
      icon="fast-forward"
      onClick={act.bind(null, parameter, ActParam(parameter, maxValue))}
    />
    <Button
      fluid
      position="absolute"
      top="16px"
      right="-20px"
      color="transparent"
      icon="undo"
      onClick={act.bind(null, parameter, ActParam(parameter, defaultValue))}
    />
    <Button
      fluid
      position="absolute"
      top="34px"
      right="-20px"
      color="transparent"
      icon="fast-backward"
      onClick={act.bind(null, parameter, ActParam(parameter, minValue))}
    />
  </Box>);
}

export const HypertorusSecondaryControls = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Tweakable Inputs">
      <LabeledControls justify="space-around">
        <LabeledControls.Item label="Heating Conductor">
          <ComboKnob
            act={act}
            color={data.heating_conductor > 50 && data.heat_output > 0 && "yellow"}
            value={parseFloat(data.heating_conductor)}
            unit="J/cm"
            minValue={50}
            defaultValue={100}
            maxValue={500}
            parameter='heating_conductor'
            icon='fire'
            help='Adjusts the rate the fusion reaction heats or cools. Higher heating values improve production at the risk of a runaway reaction.'
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Cooling Volume">
          <ComboKnob
            act={act}
            value={parseFloat(data.cooling_volume)}
            unit="L"
            minValue={50}
            defaultValue={100}
            maxValue={2000}
            parameter='cooling_volume'
            step={25}
            icon='snowflake-o'
            help="Adjusts the HFR core's internal cooling space. A smaller space will provide less cooling internally, but will move most of the coolant outside of the HFR core, where it can be rapidly cooled when not needed."
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Magnetic Constrictor">
          <ComboKnob
            act={act}
            value={parseFloat(data.magnetic_constrictor)}
            unit="m³/T"
            minValue={50}
            defaultValue={100}
            maxValue={1000}
            parameter='magnetic_constrictor'
            icon='magnet'
            flipIcon={true}
            help='Adjusts the density of the fusion reaction. Denser reactions expose more energy, but may destabilize the reaction if too much mass is involved.'
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Current Damper">
          <ComboKnob
            act={act}
            color={data.current_damper && "yellow"}
            value={parseFloat(data.current_damper)}
            unit="W"
            minValue={0}
            defaultValue={0}
            maxValue={1000}
            parameter='current_damper'
            icon='sun-o'
            help='Destabilizes the reaction. A sufficiently destabilized reaction will halt production and become endothermic, cooling the Fusion Mix instead of heating it. Reactions with more iron are harder to destabilize.'
          />
        </LabeledControls.Item>
      </LabeledControls>
    </Section>
  );
};

export const HypertorusIO = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="I/O Flow Control" height="100%" width="260px">
      <LabeledList >
        <LabeledList.Item label="Fuel Injection Rate">
          <NumberInput
            animated
            value={parseFloat(data.fuel_injection_rate)}
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
            unit="mol/s"
            minValue={.5}
            maxValue={150}
            onDrag={(e, value) => act('moderator_injection_rate', {
              moderator_injection_rate: value,
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Moderator filtering rate">
          <NumberInput
            animated
            value={parseFloat(data.mod_filtering_rate)}
            unit="mol/s"
            minValue={5}
            maxValue={200}
            onDrag={(e, value) => act('mod_filtering_rate', {
              mod_filtering_rate: value,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const HypertorusWasteRemove = (props, context) => {
  const { act, data } = useBackend(context);
  const filterTypes = data.filter_types || [];
  return (
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
  );
};

import { Box, Button, Icon, Table, Tooltip } from '../../components';
import { getGasColor, getGasLabel } from '../../constants';

/*
 * Recipe selection interface
 *
 * Displays a table of recipes with their outputs and effects, along
 * with buttons to select the active recipe and highlights on the current
 * recipe.
 * 
 * Frankly, rather ugly and a good candidate for future improvements.
 */

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
    tooltip: (v, d) => "Maximum: " + (d.baseMaximumTemperature * v).toExponential() + " K",
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

const recipeChange = {
  onComponentShouldUpdate: (lastProps, nextProps) =>
    lastProps.selectedFuelID !== nextProps.selectedFuelID
    || lastProps.enableRecipeSelection !== nextProps.enableRecipeSelection,
};

const activeChange = {
  onComponentShouldUpdate: (lastProps, nextProps) =>
    lastProps.active !== nextProps.active,
};

const MemoRow = props => {
  const {
    active,
    children,
    key,
    ...rest
  } = props;
  return (
    <Table.Row
      className={`hypertorus-recipes__row${active ? ' hypertorus-recipes__activerow' : ''}`}
      {...rest}
    >
      {children}
    </Table.Row>
  );
};

MemoRow.defaultHooks = activeChange;

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

export const HypertorusRecipes = props => {
  const {
    enableRecipeSelection: enable_recipe_selection,
    onRecipe,
    selectableFuels: selectable_fuels,
    selectedFuelID: selected_fuel_id,
    ...rest
  } = props;
  return (
    <Box overflowX="auto">
      <Table>
        <MemoRow header>
          <Table.Cell />
          <Table.Cell colspan="2">Fuel</Table.Cell>
          <Table.Cell colspan="2">Fusion Byproducts</Table.Cell>
          <Table.Cell colspan="6">Produced gases</Table.Cell>
          <Table.Cell colspan="6">Effects</Table.Cell>
        </MemoRow>
        <MemoRow header>
          <Table.Cell />
          <Table.Cell>Primary</Table.Cell>
          <Table.Cell>Secondary</Table.Cell>
          <Table.Cell colspan="2" />
          <Table.Cell>Tier 1</Table.Cell>
          <Table.Cell>Tier 2</Table.Cell>
          <Table.Cell>Tier 3</Table.Cell>
          <Table.Cell>Tier 4</Table.Cell>
          <Table.Cell>Tier 5</Table.Cell>
          <Table.Cell>Tier 6</Table.Cell>
          {
            // Lay out our pictographic headers for effects.
            recipe_effect_structure.map(item => (
              <Table.Cell key={item.param} color="label">
                <Tooltip content={item.label}>
                  {typeof(item.icon) === "string" ? (
                    <Icon className="hypertorus-recipes__icon" name={item.icon} />
                  ) : (
                    <Icon.Stack className="hypertorus-recipes__icon">
                      {item.icon.map(icon => (
                        <Icon key={icon} name={icon} />
                      ))}
                    </Icon.Stack>
                  )}
                </Tooltip>
              </Table.Cell>
            ))
          }
        </MemoRow>
        {selectable_fuels.filter(d => d.id).map((recipe, index) => {
          const active = recipe.id === selected_fuel_id;
          return (
            <MemoRow key={recipe.id} active={active}>
              <Table.Cell>
                <Button
                  icon={recipe.id === selected_fuel_id ? "times" : "power-off"}
                  disabled={!enable_recipe_selection}
                  key={recipe.id}
                  selected={recipe.id === selected_fuel_id}
                  onClick={onRecipe.bind(null, recipe.id)}
                />
              </Table.Cell>
              <GasCellItem gasid={recipe.requirements[0]} />
              <GasCellItem gasid={recipe.requirements[1]} />
              <GasCellItem gasid={recipe.fusion_byproducts[0]} />
              <GasCellItem gasid={recipe.fusion_byproducts[1]} />
              {recipe.product_gases.map(gasid => (
                <GasCellItem key={gasid} gasid={gasid} />
              ))}
              {
                recipe_effect_structure.map(item => {
                  const value = recipe[item.param];
                  // Note that the minus icon is wider than the arrow icons,
                  // so we set the width to work with both without jumping.
                  return (
                    <Table.Cell key={item.param}>
                      <Tooltip content={(item.tooltip || (v => "x"+v))(value, rest)}>
                        <Icon className="hypertorus-recipes__icon" name={effect_to_icon(value, item.scale, item.override_base || 1)} />
                      </Tooltip>
                    </Table.Cell>
                  );
                })
              }
            </MemoRow>
          );
        })}
      </Table>
    </Box>
  );
};

HypertorusRecipes.defaultHooks = recipeChange;

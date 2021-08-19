import { BooleanLike } from "common/react";
import { ComponentType, createComponentVNode, InfernoNode } from "inferno";
import { VNodeFlags } from "inferno-vnode-flags";
import { sendAct, useLocalState } from "../../../../backend";
import { Box, Button, Dropdown, NumberInput, Stack } from "../../../../components";
import { createSetPreference } from "../../data";

export type Feature<T, U = T> = {
  name: string;
  component: FeatureValue<T, U>;
  category?: string;
};

/**
 * Represents a preference.
 * T = The type you will be receiving
 * U = The type you will be sending
 */
type FeatureValue<T, U = T>
  = ComponentType<FeatureValueProps<T, U>>;

// MOTHBLOCKS TODO: Replace with real HoC's. Create them once on constructor
// and pass in the value as a prop to the created element.
type FeatureValueProps<T, U = T> = {
  // eslint-disable-next-line react/no-unused-prop-types
  act: typeof sendAct,

  // eslint-disable-next-line react/no-unused-prop-types
  featureId: string,

  // eslint-disable-next-line react/no-unused-prop-types
  handleSetValue: (newValue: U) => void;

  value: T;
};

export const ColorInput = (props: FeatureValueProps<string>) => {
  return (
    <Button onClick={() => {
      props.act("set_color_preference", {
        preference: props.featureId,
      });
    }}>
      <Stack align="center" fill>
        <Stack.Item>
          <Box style={{
            background: `#${props.value}`,
            border: "2px solid white",
            "box-sizing": "content-box",
            height: "11px",
            width: "11px",
          }} />
        </Stack.Item>

        <Stack.Item>
          Change
        </Stack.Item>
      </Stack>
    </Button>
  );
};

export type FeatureToggle = Feature<BooleanLike, boolean>;

export const CheckboxInput = (
  props: FeatureValueProps<BooleanLike, boolean>
) => {
  return (<Button.Checkbox
    checked={!!props.value}
    onClick={() => {
      props.handleSetValue(!props.value);
    }}
  />);
};

export const createDropdownInput = (
  // Map of value to display texts
  choices: Record<string, InfernoNode>,
  dropdownProps?: Record<string, unknown>,
): FeatureValue<string> => {
  return (props: FeatureValueProps<string>) => {
    // MOTHBLOCKS TODO: Sort
    return (<Dropdown
      selected={props.value}
      displayText={choices[props.value]}
      onSelected={props.handleSetValue}
      width="100%"
      options={Object.entries(choices).map(([dataValue, label]) => {
        return {
          displayText: label,
          value: dataValue,
        };
      })}
      {...dropdownProps}
    />);
  };
};

export const createNumberInput = (
  minimum: number,
  maximum: number,
): FeatureValue<number> => {
  return (props: FeatureValueProps<number>) => {
    return (<NumberInput
      onChange={(e, value) => {
        props.handleSetValue(value);
      }}
      minValue={minimum}
      maxValue={maximum}
      value={props.value}
    />);
  };
};

export const FeatureValueInput = (props: {
  feature: Feature<unknown>,
  featureId: string,
  value: unknown,

  act: typeof sendAct,
}, context) => {
  const feature = props.feature;

  const [predictedValue, setPredictedValue] = useLocalState(
    context,
    `${props.featureId}_predictedValue`,
    props.value,
  );

  const changeValue = (newValue: string) => {
    setPredictedValue(newValue);
    createSetPreference(props.act, props.featureId)(newValue);
  };

  return createComponentVNode(
    VNodeFlags.ComponentUnknown,
    feature.component,
    {
      act: props.act,
      featureId: props.featureId,

      handleSetValue: changeValue,
      value: predictedValue,
    });
};

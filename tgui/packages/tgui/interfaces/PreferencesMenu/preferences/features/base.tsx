import { InfernoNode } from "inferno";
import { sendAct, useLocalState } from "../../../../backend";
import { Box, Button, Dropdown, NumberInput, Stack } from "../../../../components";
import { createSetPreference } from "../../data";

export type Feature<T, U = T> = {
  name: string;
  createComponent: FeatureValue<T, U>;
  scope?: FeatureScope,
};

export enum FeatureScope {
  GamePreferences,
}

/**
 * Represents a preference.
 * T = The type you will be receiving
 * U = The type you will be sending
 */
// This is not ComponentType<FeatureValueProps<T, U>> as HOCs should not be
// created and used during render--it hurts reconciliation.
// Instead, the function is called, and its props used.
type FeatureValue<T, U = T>
  = (featureProps: FeatureValueProps<T, U>) => JSX.Element;

// MOTHBLOCKS TODO: Replace with real HoC's. Create them once on constructor
// and pass in the value as a prop to the created element.
type FeatureValueProps<T, U = T> = {
  act: typeof sendAct,
  featureId: string,
  handleSetValue: (newValue: U) => void;
  value: T;
};

export const createColorInput = (featureProps: FeatureValueProps<string>) => {
  return (
    <Button onClick={() => {
      featureProps.act("set_color_preference", {
        preference: featureProps.featureId,
      });
    }}>
      <Stack align="center" fill>
        <Stack.Item>
          <Box style={{
            background: `#${featureProps.value}`,
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

export const createDropdownInput = (
  // Map of value to display texts
  choices: Record<string, InfernoNode>,
  dropdownProps?: Record<string, unknown>,
): FeatureValue<string> => {
  return (featureProps: FeatureValueProps<string>) => {
    // MOTHBLOCKS TODO: Sort
    return (<Dropdown
      selected={featureProps.value}
      displayText={choices[featureProps.value]}
      onSelected={featureProps.handleSetValue}
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
  return (featureProps: FeatureValueProps<number>) => {
    return (<NumberInput
      onChange={(e, value) => {
        featureProps.handleSetValue(value);
      }}
      minValue={minimum}
      maxValue={maximum}
      value={featureProps.value}
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

  return feature.createComponent({
    act: props.act,
    featureId: props.featureId,

    handleSetValue: changeValue,
    value: predictedValue,
  });
};

import { sortBy, sortStrings } from "common/collections";
import { BooleanLike } from "common/react";
import { ComponentType, createComponentVNode, InfernoNode } from "inferno";
import { VNodeFlags } from "inferno-vnode-flags";
import { sendAct, useLocalState } from "../../../../backend";
import { Box, Button, Dropdown, NumberInput, Stack } from "../../../../components";
import { createSetPreference } from "../../data";
import { ServerPreferencesFetcher } from "../../ServerPreferencesFetcher";

const sortChoices = sortBy<[string, InfernoNode]>(([name]) => name);

export type Feature<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined,
> = {
  name: string;
  component: FeatureValue<
    TReceiving,
    TSending,
    TServerData
  >;
  // MOTHBLOCKS TODO: Subcategory and order
  category?: string;
  description?: string;
};

/**
 * Represents a preference.
 * TReceiving = The type you will be receiving
 * TSending = The type you will be sending
 * TServerData = The data the server sends through preferences.json
 */
type FeatureValue<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined,
>
  = ComponentType<FeatureValueProps<
      TReceiving,
      TSending,
      TServerData
    >>;

export type FeatureValueProps<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined,
> = {
  // eslint-disable-next-line react/no-unused-prop-types
  act: typeof sendAct,

  // eslint-disable-next-line react/no-unused-prop-types
  featureId: string,

  // eslint-disable-next-line react/no-unused-prop-types
  handleSetValue: (newValue: TSending) => void;

  // eslint-disable-next-line react/no-unused-prop-types
  serverData: TServerData | undefined,

  value: TReceiving;
};

export const FeatureColorInput = (props: FeatureValueProps<string>) => {
  return (
    <Button onClick={() => {
      props.act("set_color_preference", {
        preference: props.featureId,
      });
    }}>
      <Stack align="center" fill>
        <Stack.Item>
          <Box style={{
            background: props.value.startsWith("#")
              ? props.value
              : `#${props.value}`,
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

export const createDropdownInput = <T extends string | number = string>(
  // Map of value to display texts
  choices: Record<T, InfernoNode>,
  dropdownProps?: Record<T, unknown>,
): FeatureValue<T> => {
  return (props: FeatureValueProps<T>) => {
    return (<Dropdown
      selected={props.value}
      displayText={choices[props.value]}
      onSelected={props.handleSetValue}
      width="100%"
      options={sortChoices(Object.entries(choices))
        .map(([dataValue, label]) => {
          return {
            displayText: label,
            value: dataValue,
          };
        })}
      {...dropdownProps}
    />);
  };
};

export type FeatureChoicedServerData = {
  choices: string[];
  display_names?: Record<string, string>;
  icons?: Record<string, string>;
};

export type FeatureChoiced = Feature<string, string, FeatureChoicedServerData>

const capitalizeFirstLetter = (text: string) => (
  text.toString().charAt(0).toUpperCase() + text.toString().slice(1)
);

export const FeatureDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  const serverData = props.serverData;
  if (!serverData) {
    return null;
  }

  const displayNames = serverData.display_names
    || Object.fromEntries(
      serverData.choices.map(choice => [choice, capitalizeFirstLetter(choice)])
    );

  return (<Dropdown
    selected={props.value}
    onSelected={props.handleSetValue}
    width="100%"
    displayText={displayNames[props.value]}
    options={
      sortStrings(serverData.choices)
        .map(choice => {
          return {
            displayText: displayNames[choice],
            value: choice,
          };
        })
    }
  />);
};

type FeatureNumericData = {
  minimum: number,
  maximum: number,
  step: number,
}

export type FeatureNumeric = Feature<number, number, FeatureNumericData>;

export const FeatureNumberInput = (
  props: FeatureValueProps<number, number, FeatureNumericData>
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (<NumberInput
    onChange={(e, value) => {
      props.handleSetValue(value);
    }}
    minValue={props.serverData.minimum}
    maxValue={props.serverData.maximum}
    step={props.serverData.step}
    value={props.value}
  />);
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

  const changeValue = (newValue: unknown) => {
    setPredictedValue(newValue);
    createSetPreference(props.act, props.featureId)(newValue);
  };

  return (
    <ServerPreferencesFetcher
      render={serverData => {
        return createComponentVNode(
          VNodeFlags.ComponentUnknown,
          feature.component,
          {
            act: props.act,
            featureId: props.featureId,
            serverData: serverData && serverData[props.featureId],

            handleSetValue: changeValue,
            value: predictedValue,
          });
      }}
    />
  );
};

import { sortBy, sortStrings } from 'common/collections';
import { BooleanLike, classes } from 'common/react';
import { ComponentType, createComponentVNode, InfernoNode } from 'inferno';
import { VNodeFlags } from 'inferno-vnode-flags';
import { sendAct, useBackend, useLocalState } from '../../../../backend';
import { Box, Button, Dropdown, Input, NumberInput, Stack } from '../../../../components';
import { createSetPreference, PreferencesMenuData } from '../../data';
import { ServerPreferencesFetcher } from '../../ServerPreferencesFetcher';

export const sortChoices = sortBy<[string, InfernoNode]>(([name]) => name);

export type Feature<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined
> = {
  name: string;
  component: FeatureValue<TReceiving, TSending, TServerData>;
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
  TServerData = undefined
> = ComponentType<FeatureValueProps<TReceiving, TSending, TServerData>>;

export type FeatureValueProps<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined
> = {
  act: typeof sendAct;
  featureId: string;
  handleSetValue: (newValue: TSending) => void;
  serverData: TServerData | undefined;
  shrink?: boolean;
  value: TReceiving;
};

export const FeatureColorInput = (props: FeatureValueProps<string>) => {
  return (
    <Button
      onClick={() => {
        props.act('set_color_preference', {
          preference: props.featureId,
        });
      }}>
      <Stack align="center" fill>
        <Stack.Item>
          <Box
            style={{
              background: props.value.startsWith('#')
                ? props.value
                : `#${props.value}`,
              border: '2px solid white',
              'box-sizing': 'content-box',
              height: '11px',
              width: '11px',
              ...(props.shrink
                ? {
                  'margin': '1px',
                }
                : {}),
            }}
          />
        </Stack.Item>

        {!props.shrink && <Stack.Item>Change</Stack.Item>}
      </Stack>
    </Button>
  );
};

export type FeatureToggle = Feature<BooleanLike, boolean>;

export const CheckboxInput = (
  props: FeatureValueProps<BooleanLike, boolean>
) => {
  return (
    <Button.Checkbox
      checked={!!props.value}
      onClick={() => {
        props.handleSetValue(!props.value);
      }}
    />
  );
};

export const CheckboxInputInverse = (
  props: FeatureValueProps<BooleanLike, boolean>
) => {
  return (
    <Button.Checkbox
      checked={!props.value}
      onClick={() => {
        props.handleSetValue(!props.value);
      }}
    />
  );
};

export const createDropdownInput = <T extends string | number = string>(
  // Map of value to display texts
  choices: Record<T, InfernoNode>,
  dropdownProps?: Record<T, unknown>
): FeatureValue<T> => {
  return (props: FeatureValueProps<T>) => {
    return (
      <Dropdown
        selected={props.value}
        displayText={choices[props.value]}
        onSelected={props.handleSetValue}
        width="100%"
        options={sortChoices(Object.entries(choices)).map(
          ([dataValue, label]) => {
            return {
              displayText: label,
              value: dataValue,
            };
          }
        )}
        {...dropdownProps}
      />
    );
  };
};

export type FeatureChoicedServerData = {
  choices: string[];
  display_names?: Record<string, string>;
  icons?: Record<string, string>;
};

export type FeatureChoiced = Feature<string, string, FeatureChoicedServerData>;

const capitalizeFirstLetter = (text: string) =>
  text
    .toString()
    .charAt(0)
    .toUpperCase() + text.toString().slice(1);

export const StandardizedDropdown = (props: {
  choices: string[];
  disabled?: boolean;
  displayNames: Record<string, InfernoNode>;
  onSetValue: (newValue: string) => void;
  value: string;
}) => {
  const { choices, disabled, displayNames, onSetValue, value } = props;

  return (
    <Dropdown
      disabled={disabled}
      selected={value}
      onSelected={onSetValue}
      width="100%"
      displayText={displayNames[value]}
      options={choices.map((choice) => {
        return {
          displayText: displayNames[choice],
          value: choice,
        };
      })}
    />
  );
};

export const FeatureDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData> & {
    disabled?: boolean;
  }
) => {
  const serverData = props.serverData;
  if (!serverData) {
    return null;
  }

  const displayNames =
    serverData.display_names ||
    Object.fromEntries(
      serverData.choices.map((choice) => [
        choice,
        capitalizeFirstLetter(choice),
      ])
    );

  return (
    <StandardizedDropdown
      choices={sortStrings(serverData.choices)}
      disabled={props.disabled}
      displayNames={displayNames}
      onSetValue={props.handleSetValue}
      value={props.value}
    />
  );
};

export type FeatureWithIcons<T> = Feature<
  { value: T },
  T,
  FeatureChoicedServerData
>;

export const FeatureIconnedDropdownInput = (
  props: FeatureValueProps<
    {
      value: string;
    },
    string,
    FeatureChoicedServerData
  >
) => {
  const serverData = props.serverData;
  if (!serverData) {
    return null;
  }

  const icons = serverData.icons;

  const textNames =
    serverData.display_names ||
    Object.fromEntries(
      serverData.choices.map((choice) => [
        choice,
        capitalizeFirstLetter(choice),
      ])
    );

  const displayNames = Object.fromEntries(
    Object.entries(textNames).map(([choice, textName]) => {
      let element: InfernoNode = textName;

      if (icons && icons[choice]) {
        const icon = icons[choice];
        element = (
          <Stack>
            <Stack.Item>
              <Box
                className={classes(['preferences32x32', icon])}
                style={{
                  'transform': 'scale(0.8)',
                }}
              />
            </Stack.Item>

            <Stack.Item grow>{element}</Stack.Item>
          </Stack>
        );
      }

      return [choice, element];
    })
  );

  return (
    <StandardizedDropdown
      choices={sortStrings(serverData.choices)}
      displayNames={displayNames}
      onSetValue={props.handleSetValue}
      value={props.value.value}
    />
  );
};

export type FeatureNumericData = {
  minimum: number;
  maximum: number;
  step: number;
};

export type FeatureNumeric = Feature<number, number, FeatureNumericData>;

export const FeatureNumberInput = (
  props: FeatureValueProps<number, number, FeatureNumericData>
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <NumberInput
      onChange={(e, value) => {
        props.handleSetValue(value);
      }}
      minValue={props.serverData.minimum}
      maxValue={props.serverData.maximum}
      step={props.serverData.step}
      value={props.value}
    />
  );
};

export const FeatureValueInput = (
  props: {
    feature: Feature<unknown>;
    featureId: string;
    shrink?: boolean;
    value: unknown;

    act: typeof sendAct;
  },
  context
) => {
  const { data } = useBackend<PreferencesMenuData>(context);

  const feature = props.feature;

  const [predictedValue, setPredictedValue] = useLocalState(
    context,
    `${props.featureId}_predictedValue_${data.active_slot}`,
    props.value
  );

  const changeValue = (newValue: unknown) => {
    setPredictedValue(newValue);
    createSetPreference(props.act, props.featureId)(newValue);
  };

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        return createComponentVNode(
          VNodeFlags.ComponentUnknown,
          feature.component,
          {
            act: props.act,
            featureId: props.featureId,
            serverData: serverData && serverData[props.featureId],
            shrink: props.shrink,

            handleSetValue: changeValue,
            value: predictedValue,
          }
        );
      }}
    />
  );
};

export type FeatureShortTextData = {
  maximum_length: number;
};

export const FeatureShortTextInput = (
  props: FeatureValueProps<string, string, FeatureShortTextData>
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <Input
      width="100%"
      value={props.value}
      maxLength={props.serverData.maximum_length}
      onChange={(_, value) => props.handleSetValue(value)}
    />
  );
};

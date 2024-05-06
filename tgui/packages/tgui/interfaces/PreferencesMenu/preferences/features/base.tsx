import { sortBy } from 'common/collections';
import { BooleanLike } from 'common/react';
import {
  ComponentType,
  createElement,
  ReactNode,
  useEffect,
  useState,
} from 'react';

import { sendAct, useBackend } from '../../../../backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NumberInput,
  Slider,
  Stack,
} from '../../../../components';
import { createSetPreference, PreferencesMenuData } from '../../data';
import { ServerPreferencesFetcher } from '../../ServerPreferencesFetcher';

export const sortChoices = (array: [string, ReactNode][]) =>
  sortBy(array, ([name]) => name);

export type Feature<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined,
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
  TServerData = undefined,
> = ComponentType<FeatureValueProps<TReceiving, TSending, TServerData>>;

export type FeatureValueProps<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined,
> = Readonly<{
  act: typeof sendAct;
  featureId: string;
  handleSetValue: (newValue: TSending) => void;
  serverData: TServerData | undefined;
  shrink?: boolean;
  value: TReceiving;
}>;

export const FeatureColorInput = (props: FeatureValueProps<string>) => {
  return (
    <Button
      onClick={() => {
        props.act('set_color_preference', {
          preference: props.featureId,
        });
      }}
    >
      <Stack align="center" fill>
        <Stack.Item>
          <Box
            style={{
              background: props.value.startsWith('#')
                ? props.value
                : `#${props.value}`,
              border: '2px solid white',
              boxSizing: 'content-box',
              height: '11px',
              width: '11px',
              ...(props.shrink
                ? {
                    margin: '1px',
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
  props: FeatureValueProps<BooleanLike, boolean>,
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
  props: FeatureValueProps<BooleanLike, boolean>,
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

export function createDropdownInput<T extends string | number = string>(
  // Map of value to display texts
  choices: Record<T, ReactNode>,
  dropdownProps?: Record<T, unknown>,
): FeatureValue<T> {
  return (props: FeatureValueProps<T>) => {
    return (
      <Dropdown
        selected={choices[props.value] as string}
        onSelected={props.handleSetValue}
        width="100%"
        options={sortChoices(Object.entries(choices)).map(
          ([dataValue, label]) => {
            return {
              displayText: label,
              value: dataValue,
            };
          },
        )}
        {...dropdownProps}
      />
    );
  };
}

export type FeatureChoicedServerData = {
  choices: string[];
  display_names?: Record<string, string>;
  icons?: Record<string, string>;
};

export type FeatureChoiced = Feature<string, string, FeatureChoicedServerData>;

export type FeatureNumericData = {
  minimum: number;
  maximum: number;
  step: number;
};

export type FeatureNumeric = Feature<number, number, FeatureNumericData>;

export const FeatureNumberInput = (
  props: FeatureValueProps<number, number, FeatureNumericData>,
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <NumberInput
      onChange={(value) => {
        props.handleSetValue(value);
      }}
      minValue={props.serverData.minimum}
      maxValue={props.serverData.maximum}
      step={props.serverData.step}
      value={props.value}
    />
  );
};

export const FeatureSliderInput = (
  props: FeatureValueProps<number, number, FeatureNumericData>,
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <Slider
      onChange={(e, value) => {
        props.handleSetValue(value);
      }}
      minValue={props.serverData.minimum}
      maxValue={props.serverData.maximum}
      step={props.serverData.step}
      value={props.value}
      stepPixelSize={10}
    />
  );
};

export const FeatureValueInput = (props: {
  feature: Feature<unknown>;
  featureId: string;
  shrink?: boolean;
  value: unknown;

  act: typeof sendAct;
}) => {
  const { data } = useBackend<PreferencesMenuData>();

  const feature = props.feature;

  const [predictedValue, setPredictedValue] = useState(props.value);

  const changeValue = (newValue: unknown) => {
    setPredictedValue(newValue);
    createSetPreference(props.act, props.featureId)(newValue);
  };

  useEffect(() => {
    setPredictedValue(props.value);
  }, [data.active_slot, props.value]);

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        return createElement(feature.component, {
          act: props.act,
          featureId: props.featureId,
          serverData: serverData?.[props.featureId] as any,
          shrink: props.shrink,

          handleSetValue: changeValue,
          value: predictedValue,
        });
      }}
    />
  );
};

export type FeatureShortTextData = {
  maximum_length: number;
};

export const FeatureShortTextInput = (
  props: FeatureValueProps<string, string, FeatureShortTextData>,
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

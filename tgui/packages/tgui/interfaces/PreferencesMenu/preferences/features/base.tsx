import { sortBy } from 'es-toolkit';
import {
  type ComponentType,
  createElement,
  type ReactNode,
  useEffect,
  useState,
} from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NumberInput,
  Slider,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { createSetPreference, type PreferencesMenuData } from '../../types';
import { useServerPrefs } from '../../useServerPrefs';

export function sortChoices(array: [string, ReactNode][]) {
  return sortBy(array, [([name]) => name]);
}

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
  featureId: string;
  handleSetValue: (newValue: TSending) => void;
  serverData: TServerData | undefined;
  shrink?: boolean;
  value: TReceiving;
}>;

export function FeatureColorInput(props: FeatureValueProps<string>) {
  const { act } = useBackend<PreferencesMenuData>();
  const { featureId, shrink, value } = props;

  return (
    <Button
      onClick={() => {
        act('set_color_preference', {
          preference: featureId,
        });
      }}
    >
      <Stack align="center" fill>
        <Stack.Item>
          <Box
            style={{
              background: value.startsWith('#') ? value : `#${value}`,
              border: '2px solid white',
              boxSizing: 'content-box',
              height: '11px',
              width: '11px',
              ...(shrink
                ? {
                    margin: '1px',
                  }
                : {}),
            }}
          />
        </Stack.Item>

        {!shrink && <Stack.Item>Change</Stack.Item>}
      </Stack>
    </Button>
  );
}

export type FeatureToggle = Feature<BooleanLike, boolean>;

export function CheckboxInput(props: FeatureValueProps<BooleanLike, boolean>) {
  const { handleSetValue, value } = props;

  return (
    <Button.Checkbox
      checked={!!value}
      onClick={() => {
        handleSetValue(!value);
      }}
    />
  );
}

export function CheckboxInputInverse(
  props: FeatureValueProps<BooleanLike, boolean>,
) {
  const { handleSetValue, value } = props;

  return (
    <Button.Checkbox
      checked={!value}
      onClick={() => {
        handleSetValue(!value);
      }}
    />
  );
}

export function createDropdownInput<T extends string | number = string>(
  // Map of value to display texts
  choices: Record<T, ReactNode>,
  dropdownProps?: Record<T, unknown>,
): FeatureValue<T> {
  return (props: FeatureValueProps<T>) => {
    const { handleSetValue, value } = props;

    return (
      <Dropdown
        selected={choices[value] as string}
        onSelected={handleSetValue}
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

export function FeatureNumberInput(
  props: FeatureValueProps<number, number, FeatureNumericData>,
) {
  const { serverData, handleSetValue, value } = props;

  return (
    <NumberInput
      onChange={(value) => handleSetValue(value)}
      disabled={!serverData}
      minValue={serverData?.minimum || 0}
      maxValue={serverData?.maximum || 100}
      step={serverData?.step || 1}
      value={value}
    />
  );
}

export function FeatureSliderInput(
  props: FeatureValueProps<number, number, FeatureNumericData>,
) {
  const { serverData, handleSetValue, value } = props;

  return (
    <Slider
      onChange={(e, value) => {
        handleSetValue(value);
      }}
      disabled={!serverData}
      minValue={serverData?.minimum || 0}
      maxValue={serverData?.maximum || 100}
      step={serverData?.step || 1}
      value={value}
      stepPixelSize={10}
    />
  );
}

type FeatureValueInputProps = {
  feature: Feature<unknown>;
  featureId: string;
  shrink?: boolean;
  value: unknown;
};

export function FeatureValueInput(props: FeatureValueInputProps) {
  const { act, data } = useBackend<PreferencesMenuData>();

  const feature = props.feature;

  const [predictedValue, setPredictedValue] = useState(props.value);

  function changeValue(newValue: unknown) {
    setPredictedValue(newValue);
    createSetPreference(act, props.featureId)(newValue);
  }

  useEffect(() => {
    setPredictedValue(props.value);
  }, [data.active_slot, props.value]);

  const serverData = useServerPrefs();

  return createElement(feature.component, {
    featureId: props.featureId,
    serverData: serverData?.[props.featureId] as any,
    shrink: props.shrink,
    handleSetValue: changeValue,
    value: predictedValue,
  });
}

type FeatureShortTextData = {
  maximum_length: number;
};

export function FeatureShortTextInput(
  props: FeatureValueProps<string, string, FeatureShortTextData>,
) {
  const { serverData, value, handleSetValue } = props;

  return (
    <Input
      disabled={!serverData}
      fluid
      value={value}
      maxLength={serverData?.maximum_length}
      onBlur={handleSetValue}
    />
  );
}

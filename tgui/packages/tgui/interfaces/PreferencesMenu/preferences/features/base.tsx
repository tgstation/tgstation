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
  Button,
  Dropdown,
  Input,
  NumberInput,
  Slider,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import {
  type CharacterPreferencesData,
  createSetPreference,
  type PreferencesMenuData,
} from '../../types';
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
  character_preferences: CharacterPreferencesData;
}>;

type ToggleProps = {
  checked: boolean;
  onClick: () => void;
};

function Toggle(props: ToggleProps) {
  const { checked, onClick } = props;
  return (
    <Stack
      className={classes(['Toggle', checked && 'Toggle--checked'])}
      onClick={onClick}
    >
      <div className="Toggle__Switch" />
    </Stack>
  );
}

export type FeatureToggle = Feature<BooleanLike, boolean>;

export function CheckboxInput(props: FeatureValueProps<BooleanLike, boolean>) {
  const { value, handleSetValue } = props;
  return <Toggle checked={!!value} onClick={() => handleSetValue(!value)} />;
}

export function CheckboxInputInverse(
  props: FeatureValueProps<BooleanLike, boolean>,
) {
  const { value, handleSetValue } = props;
  return <Toggle checked={!value} onClick={() => handleSetValue(!value)} />;
}

export function FeatureColorInput(props: FeatureValueProps<string>) {
  const { act } = useBackend<PreferencesMenuData>();
  const { value, featureId, shrink } = props;
  return (
    <Button
      p={0}
      className="ColorInput"
      onClick={() => {
        act('set_color_preference', {
          preference: featureId,
        });
      }}
    >
      <Stack fill g={0}>
        {!shrink && <div className="ColorInput__Text">Изменить</div>}
        <div
          className="ColorInput__Color"
          style={{ background: value.startsWith('#') ? value : `#${value}` }}
        />
      </Stack>
    </Button>
  );
}

export function createDropdownInput<T extends string | number = string>(
  // Map of value to display texts
  choices: Record<T, ReactNode>,
  dropdownProps?: Record<T, unknown>,
): FeatureValue<T> {
  return (props: FeatureValueProps<T>) => {
    const { value, handleSetValue } = props;
    return (
      <Dropdown
        selected={choices[value] as string}
        onSelected={handleSetValue}
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
  const { value, serverData, handleSetValue } = props;
  return (
    <NumberInput
      disabled={!serverData}
      value={value}
      minValue={serverData?.minimum || 0}
      maxValue={serverData?.maximum || 100}
      step={serverData?.step || 1}
      onChange={(value) => handleSetValue(value)}
    />
  );
}

export function FeatureSliderInput(
  props: FeatureValueProps<number, number, FeatureNumericData>,
) {
  const { value, serverData, handleSetValue } = props;
  return (
    <Slider
      width="100%"
      disabled={!serverData}
      minValue={serverData?.minimum || 0}
      maxValue={serverData?.maximum || 100}
      step={serverData?.step || 1}
      value={value}
      onChange={(e, value) => {
        handleSetValue(value);
      }}
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
    character_preferences: data.character_preferences,
  });
}

type FeatureShortTextData = {
  maximum_length: number;
};

export function FeatureShortTextInput(
  props: FeatureValueProps<string, string, FeatureShortTextData>,
) {
  const { value, serverData, handleSetValue } = props;
  return (
    <Input
      fluid
      disabled={!serverData}
      value={value}
      maxLength={serverData?.maximum_length}
      onBlur={handleSetValue}
    />
  );
}

export const FeatureTextInput = (
  props: FeatureValueProps<string, string, FeatureShortTextData>,
) => {
  if (!props.serverData) {
    return <Stack>Loading...</Stack>;
  }

  return (
    <TextArea
      fluid
      expensive
      value={props.value}
      maxLength={props.serverData.maximum_length}
      onChange={(value) => props.handleSetValue(value)}
    />
  );
};

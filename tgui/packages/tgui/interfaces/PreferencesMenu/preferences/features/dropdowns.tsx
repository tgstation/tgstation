import {
  type ComponentProps,
  type ReactNode,
  useEffect,
  useState,
} from 'react';
import { Box, Dropdown, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';

import type {
  Feature,
  FeatureChoicedServerData,
  FeatureValueProps,
} from './base';

type DropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
> &
  Partial<{
    disabled: boolean;
    buttons: boolean;
  }>;

type IconnedDropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
>;

export type FeatureWithIcons<T> = Feature<string, T, FeatureChoicedServerData>;

type DropdownOptions = ComponentProps<typeof Dropdown>['options'];

export function FeatureDropdownInput(props: DropdownInputProps) {
  const { serverData, disabled, buttons, handleSetValue, value } = props;

  const [dropdownOptions, setDropdownOptions] = useState<DropdownOptions>([]);

  function populateOptions() {
    if (!serverData) return;

    const { choices = [] } = serverData;

    const newOptions: DropdownOptions = [];

    for (const choice of choices) {
      const displayText: ReactNode = serverData.display_names
        ? serverData.display_names[choice]
        : capitalizeFirst(choice);

      newOptions.push({
        displayText,
        value: choice,
      });
    }

    setDropdownOptions(newOptions);
  }

  useEffect(() => {
    if (serverData) {
      populateOptions();
    }
  }, [serverData]);

  const displayText = serverData?.display_names?.[value] || String(value);

  return (
    <Dropdown
      buttons={buttons}
      disabled={disabled || !serverData}
      onSelected={handleSetValue}
      displayText={displayText ? capitalizeFirst(displayText) : ''}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

export function FeatureIconnedDropdownInput(props: IconnedDropdownInputProps) {
  const { serverData, handleSetValue, value } = props;

  const [dropdownOptions, setDropdownOptions] = useState<DropdownOptions>([]);

  function populateOptions() {
    if (!serverData) return;
    const { icons = {}, choices = [] } = serverData;

    const newOptions: DropdownOptions = [];

    for (const choice of choices) {
      let displayText: ReactNode = serverData.display_names?.[choice]
        ? serverData.display_names?.[choice]
        : capitalizeFirst(choice);

      if (serverData.icons?.[choice]) {
        displayText = (
          <Stack>
            <Stack.Item>
              <Box
                className={classes(['preferences32x32', icons[choice]])}
                style={{ transform: 'scale(0.8)' }}
              />
            </Stack.Item>
            <Stack.Item grow>{displayText}</Stack.Item>
          </Stack>
        );
      }

      newOptions.push({
        displayText,
        value: choice,
      });
    }

    setDropdownOptions(newOptions);
  }

  useEffect(() => {
    if (serverData) {
      populateOptions();
    }
  }, [serverData]);

  const displayText = serverData?.display_names?.[value] || String(value);

  return (
    <Dropdown
      buttons
      displayText={displayText ? capitalizeFirst(displayText) : ''}
      onSelected={handleSetValue}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

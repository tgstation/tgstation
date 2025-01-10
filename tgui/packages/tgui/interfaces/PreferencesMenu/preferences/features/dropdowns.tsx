import { ComponentProps, ReactNode, useEffect, useState } from 'react';
import { Box, Dropdown, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';

import { Feature, FeatureChoicedServerData, FeatureValueProps } from './base';

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

  const display_names = serverData?.display_names || {};

  const [dropdownOptions, setDropdownOptions] = useState<DropdownOptions>([]);

  function populateOptions() {
    if (!serverData) return;
    let newOptions: DropdownOptions = [];

    for (const choice of serverData.choices) {
      let displayText: ReactNode = display_names
        ? display_names[choice]
        : capitalizeFirst(choice);

      newOptions.push({
        displayText,
        value: choice,
      });
    }

    setDropdownOptions(newOptions);
  }

  useEffect(() => {
    if (serverData && dropdownOptions.length === 0) {
      populateOptions();
    }
  }, [serverData]);

  let display_text = value;
  if (display_names) {
    display_text = display_names[value];
  }

  return (
    <Dropdown
      buttons={buttons}
      disabled={disabled || !serverData}
      onSelected={handleSetValue}
      displayText={display_text ? capitalizeFirst(display_text) : ''}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

export function FeatureIconnedDropdownInput(props: IconnedDropdownInputProps) {
  const { serverData, handleSetValue, value } = props;

  // Skeleton arrays so we can load
  const display_names: Record<string, string> = serverData?.display_names || {};
  const icons: Record<string, string> = serverData?.icons || {};

  const [dropdownOptions, setDropdownOptions] = useState<DropdownOptions>([]);

  function populateOptions() {
    if (!serverData) return;
    let newOptions: DropdownOptions = [];

    for (const choice of serverData.choices) {
      let displayText: ReactNode = display_names
        ? display_names[choice]
        : capitalizeFirst(choice);

      if (icons?.[choice]) {
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
    if (serverData && dropdownOptions.length === 0) {
      populateOptions();
    }
  }, [serverData]);

  let display_text = value;
  if (display_names) {
    display_text = display_names[value];
  }

  return (
    <Dropdown
      buttons
      displayText={display_text ? capitalizeFirst(display_text) : ''}
      onSelected={handleSetValue}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

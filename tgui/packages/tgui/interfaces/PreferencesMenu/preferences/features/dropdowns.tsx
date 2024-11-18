import { ReactNode } from 'react';
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

export function FeatureDropdownInput(props: DropdownInputProps) {
  const { serverData, disabled, buttons, handleSetValue, value } = props;

  if (!serverData) {
    return null;
  }

  const { choices, display_names } = serverData;

  const dropdownOptions = choices.map((choice) => {
    let displayText: ReactNode = display_names
      ? display_names[choice]
      : capitalizeFirst(choice);

    return {
      displayText,
      value: choice,
    };
  });

  let display_text = value;
  if (display_names) {
    display_text = display_names[value];
  }

  return (
    <Dropdown
      buttons={buttons}
      disabled={disabled}
      onSelected={handleSetValue}
      displayText={capitalizeFirst(display_text)}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

export function FeatureIconnedDropdownInput(props: IconnedDropdownInputProps) {
  const { serverData, handleSetValue, value } = props;

  if (!serverData) {
    return null;
  }

  const { choices, display_names, icons } = serverData;

  const dropdownOptions = choices.map((choice) => {
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

    return {
      displayText,
      value: choice,
    };
  });

  let display_text = value;
  if (display_names) {
    display_text = display_names[value];
  }

  return (
    <Dropdown
      buttons
      displayText={capitalizeFirst(display_text)}
      onSelected={handleSetValue}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

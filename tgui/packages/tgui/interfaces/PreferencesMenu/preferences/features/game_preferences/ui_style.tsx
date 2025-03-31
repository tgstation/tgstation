import { Box, Dropdown, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureValueProps,
  sortChoices,
} from '../base';

function UIStyleInput(
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) {
  const { serverData, value } = props;
  if (!serverData) {
    return null;
  }

  const { icons } = serverData;

  if (!icons) {
    return <Box color="red">ui_style had no icons!</Box>;
  }

  const choices = Object.fromEntries(
    Object.entries(icons).map(([name, icon]) => {
      return [
        name,
        <Stack key={name}>
          <Stack.Item>
            <Box
              className={classes(['preferences64x32', icon])}
              style={{
                transform: 'scale(0.8)',
              }}
            />
          </Stack.Item>

          <Stack.Item grow>{name}</Stack.Item>
        </Stack>,
      ];
    }),
  );

  return (
    <Dropdown
      selected={value}
      clipSelectedText={false}
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
    />
  );
}

export const UI_style: FeatureChoiced = {
  name: 'UI Style',
  category: 'UI',
  component: UIStyleInput,
};

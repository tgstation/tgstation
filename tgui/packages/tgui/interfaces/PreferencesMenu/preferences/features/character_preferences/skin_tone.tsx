import { sortBy } from 'es-toolkit';
import { useMemo } from 'react';
import { Box, Dropdown, Stack } from 'tgui-core/components';

import type {
  Feature,
  FeatureChoicedServerData,
  FeatureValueProps,
} from '../base';

type HexValue = {
  lightness: number;
  value: string;
};

type SkinToneServerData = FeatureChoicedServerData & {
  display_names: NonNullable<FeatureChoicedServerData['display_names']>;
  to_hex: Record<string, HexValue>;
};

function sortHexValues(array: [string, HexValue][]) {
  return sortBy(array, [([, hexValue]) => -hexValue.lightness]);
}

export const skin_tone: Feature<string, string, SkinToneServerData> = {
  name: 'Skin tone',
  component: (props: FeatureValueProps<string, string, SkinToneServerData>) => {
    const { handleSetValue, serverData } = props;

    if (!serverData) {
      return null;
    }

    const value = { value: props.value };

    const displayNames = useMemo(() => {
      const sorted = sortHexValues(Object.entries(serverData.to_hex));

      return sorted.map(([key, colorInfo]) => {
        const displayName = serverData.display_names[key];

        return {
          value: key,
          displayText: (
            <Stack align="center" fill key={key}>
              <Stack.Item>
                <Box
                  style={{
                    background: colorInfo.value,
                    boxSizing: 'content-box',
                    height: '11px',
                    width: '11px',
                  }}
                />
              </Stack.Item>

              <Stack.Item grow>{displayName}</Stack.Item>
            </Stack>
          ),
        };
      });
    }, [serverData.display_names]);

    return (
      <Dropdown
        buttons
        displayText={
          displayNames.find((option) => option.value === value.value)
            ?.displayText
        }
        onSelected={(value) => handleSetValue(value)}
        options={displayNames}
        selected={value.value}
        width="100%"
      />
    );
  },
};

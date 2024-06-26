import { sortBy } from 'common/collections';
import {
  Feature,
  FeatureChoicedServerData,
  FeatureValueProps,
  HexValue,
  StandardizedPalette,
} from '../base';

type SkinToneServerData = FeatureChoicedServerData & {
  display_names: NonNullable<FeatureChoicedServerData['display_names']>;
  to_hex: Record<string, HexValue>;
};

const sortHexValues = sortBy<[string, HexValue]>(
  ([_, hexValue]) => -hexValue.lightness,
);

export const skin_tone: Feature<string, string, SkinToneServerData> = {
  name: 'Skin Tone',
  component: (props: FeatureValueProps<string, string, SkinToneServerData>) => {
    const { handleSetValue, serverData, value } = props;

    if (!serverData) {
      return null;
    }

    return (
      <StandardizedPalette
        choices={sortHexValues(Object.entries(serverData.to_hex)).map(
          ([key]) => key,
        )}
        choices_to_hex={Object.fromEntries(
          Object.entries(serverData.to_hex).map(([key, hex]) => [
            key,
            hex.value,
          ]),
        )}
        displayNames={serverData.display_names}
        onSetValue={handleSetValue}
        value={value}
      />
    );
  },
};

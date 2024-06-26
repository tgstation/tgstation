import {
  FeatureColorInput,
  Feature,
  FeatureChoiced,
  FeatureValueProps,
  FeatureDropdownInput,
  StandardizedPalette,
} from './base';

const eyePresets = {
  // these need to be short color (3 byte) compatible
  '#aaccff': 'Baby Blue',
  '#0099bb': 'Blue-Green',
  '#3399ff': 'Light Blue',
  '#0066ff': 'Blue',
  '#337788': 'Teal Blue',
  '#005577': 'Dark Cerulean Blue',
  '#889988': 'Artichoke Green',
  '#447766': 'Green-Blue',
  '#117744': 'Teal Green',
  '#336611': 'Forest Green',
  '#aaaa66': 'Hazel',
  '#554411': 'Brown-Green',
  '#664433': 'Brown',
  '#663300': 'Rich Brown',
  '#441100': 'Deep Brown',
  '#884400': 'Amber',
  '#667788': 'Gray',
  '#445566': 'Deep Gray',
  '#990099': 'Alexandria Purple',
  '#eeeeee': 'Albino White',
  '#ccaaaa': 'Albino Pink',
  '#bbddee': 'Albino Blue',
};

const hairPresets = {
  // these need to be short color (3 byte) compatible
  '#111111': 'Black',
  '#222222': 'Off Black',
  '#332222': 'Deep Brown',
  '#443322': 'Dark Brown',
  '#443333': 'Medium Dark Brown',
  '#553333': 'Dark Chestnut Brown',
  '#664444': 'Light Chestnut Brown',
  '#554433': 'Dark Golden Brown',
  '#997766': 'Light Ash Brown',
  '#aa8866': 'Light Golden Brown',
  '#bb9977': 'Dark Honey Blonde',
  '#ddbb99': 'Light Ash Blonde',
  '#eeccaa': 'Light Blonde',
  '#eeddbb': 'Bleached Blonde',
  '#666666': 'Dark Gray',
  '#999999': 'Medium Gray',
  '#bbbbbb': 'Light Gray',
  '#ffeeee': 'White',
  '#884444': 'Soft Auburn',
  '#bb5544': 'Soft Terracotta',
  '#aa5500': 'Ginger Brown',
  '#cc5522': 'Ginger Orange',
  '#ff0000': 'Vibrant Red',
  '#aa0000': 'Simply Red',
  '#ff7700': 'Vibrant Orange',
  '#ffff00': 'Vibrant Yellow',
  '#aa9900': 'Simply Yellow',
  '#00ff00': 'Vibrant Green',
  '#00aa00': 'Simply Green',
  '#00ccaa': 'Turqouise',
  '#00ffff': 'Vibrant Cyan',
  '#00aaaa': 'Simply Cyan',
  '#229988': 'Teal',
  '#0000ff': 'Vibrant Blue',
  '#0000aa': 'Simply Blue',
  '#6600ff': 'Vibrant Indigo',
  '#9922ff': 'Purple',
  '#8800ff': 'Violet',
  '#550088': 'Deep Purple',
  '#ff00ff': 'Vibrant Magenta',
  '#aa00aa': 'Simply Magenta',
  '#ff0066': 'Raspberry',
  '#ff2288': 'Hot Pink',
  '#ff99bb': 'Pink',
  '#ee8888': 'Faded Pink',
};

export const eye_color: Feature<string> = {
  name: 'Eye Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(eyePresets)}
        displayNames={eyePresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="100%"
        includeHex
      />
    );
  },
};

export const gradient_color: Feature<string> = {
  name: 'Gradient Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const facial_hair_gradient: FeatureChoiced = {
  name: 'Facial hair gradient',
  component: FeatureDropdownInput,
};

export const facial_hair_gradient_color: Feature<string> = {
  name: 'Facial Hair Gradient Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const facial_hair_color: Feature<string> = {
  name: 'Facial Hair Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const hair_color: Feature<string> = {
  name: 'Hair Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const hair_gradient: FeatureChoiced = {
  name: 'Hair gradient',
  component: FeatureDropdownInput,
};

export const hair_gradient_color: Feature<string> = {
  name: 'Hair Gradient Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const feature_human_ears: FeatureChoiced = {
  name: 'Ears',
  component: FeatureDropdownInput,
};

export const feature_human_tail: FeatureChoiced = {
  name: 'Tail',
  component: FeatureDropdownInput,
};

export const feature_lizard_legs: FeatureChoiced = {
  name: 'Legs',
  component: FeatureDropdownInput,
};

export const feature_lizard_spines: FeatureChoiced = {
  name: 'Spines',
  component: FeatureDropdownInput,
};

export const feature_lizard_tail: FeatureChoiced = {
  name: 'Tail',
  component: FeatureDropdownInput,
};

export const feature_mcolor: Feature<string> = {
  name: 'Mutant color',
  component: FeatureColorInput,
};

export const feature_mcolor_secondary: Feature<string> = {
  name: 'Mutant Secondary color',
  component: FeatureColorInput,
};

export const underwear_color: Feature<string> = {
  name: 'Underwear color',
  component: FeatureColorInput,
};

export const socks_color: Feature<string> = {
  name: 'Socks color',
  component: FeatureColorInput,
};

export const feature_vampire_status: Feature<string> = {
  name: 'Vampire status',
  component: FeatureDropdownInput,
};

export const heterochromatic: Feature<string> = {
  name: 'Heterochromatic (Right Eye) color',
  component: FeatureColorInput,
};

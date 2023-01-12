import { Feature, FeatureColorInput, FeatureDropdownInput, FeatureShortTextInput } from '../base';

export const pda_color: Feature<string> = {
  name: 'PDA color',
  category: 'GAMEPLAY',
  description: 'The background color of your PDA.',
  component: FeatureColorInput,
};

export const pda_style: Feature<string> = {
  name: 'PDA style',
  category: 'GAMEPLAY',
  description: 'The style of your equipped PDA. Changes font.',
  component: FeatureDropdownInput,
};

export const pda_ringtone: Feature<string> = {
  name: 'PDA Ringtone',
  description: "The ringtone you'll hear when someone sends you a PDA message.",
  component: FeatureShortTextInput,
};

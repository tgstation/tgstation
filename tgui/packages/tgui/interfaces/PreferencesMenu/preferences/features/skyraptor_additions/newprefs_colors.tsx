import { FeatureTriColorInput, FeatureColorInput, Feature, FeatureChoiced, FeatureDropdownInput, FeatureValueProps, FeatureChoicedServerData } from '../base';

export const frills_color: Feature<string> = {
  name: 'Frills color',
  component: FeatureColorInput,
};

export const horns_color: Feature<string> = {
  name: 'Frills color',
  component: FeatureColorInput,
};



export const feature_tricolor_alpha: Feature<string[]> = {
  name: 'Tricolor Alpha',
  component: FeatureTriColorInput,
};

export const feature_tricolor_beta: Feature<string[]> = {
  name: 'Tricolor Beta',
  component: FeatureTriColorInput,
};
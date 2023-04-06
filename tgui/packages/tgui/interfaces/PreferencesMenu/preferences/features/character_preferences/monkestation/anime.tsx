import { FeatureChoiced, Feature, FeatureDropdownInput, FeatureColorInput } from '../../base';

export const feature_animecolor: Feature<string> = {
  name: 'Anime color',
  component: FeatureColorInput,
};

export const feature_anime_top: FeatureChoiced = {
  name: 'Anime Headpiece',
  component: FeatureDropdownInput,
};

export const feature_anime_middle: FeatureChoiced = {
  name: 'Anime Centerpiece',
  component: FeatureDropdownInput,
};

export const feature_anime_bottom: FeatureChoiced = {
  name: 'Anime Lowerpiece',
  component: FeatureDropdownInput,
};

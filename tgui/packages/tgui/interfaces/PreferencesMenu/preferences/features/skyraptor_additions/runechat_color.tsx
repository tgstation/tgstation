import { FeatureColorInput, Feature, FeatureChoiced, FeatureDropdownInput, FeatureValueProps, FeatureChoicedServerData } from '../base';

export const runechat_color: Feature<string> = {
  name: 'Runechat Color',
  component: FeatureColorInput,
};
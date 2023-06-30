import { FeatureColorInput, Feature, FeatureChoiced, FeatureDropdownInput, FeatureValueProps, FeatureChoicedServerData } from '../base';

export const feature_slugcat_tail: FeatureChoiced = {
  name: 'Tail',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};
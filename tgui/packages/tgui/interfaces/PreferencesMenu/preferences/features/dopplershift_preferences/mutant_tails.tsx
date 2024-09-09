import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const feature_dog_tail: FeatureChoiced = {
  name: 'Tail',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

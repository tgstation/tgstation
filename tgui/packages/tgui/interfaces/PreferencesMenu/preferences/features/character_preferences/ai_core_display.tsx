import {
  FeatureIconnedDropdownInput,
  FeatureValueProps,
  FeatureChoicedServerData,
  FeatureChoiced,
} from '../base';

export const preferred_ai_core_display: FeatureChoiced = {
  name: 'AI Core Display',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureIconnedDropdownInput buttons {...props} />;
  },
};

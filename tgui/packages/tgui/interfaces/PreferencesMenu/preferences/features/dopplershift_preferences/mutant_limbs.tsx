import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const head_type: FeatureChoiced = {
  name: 'Head Type',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const chest_type: FeatureChoiced = {
  name: 'Chest Type',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const arm_r_type: FeatureChoiced = {
  name: 'Arm Right Type',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const arm_l_type: FeatureChoiced = {
  name: 'Arm Left Type',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const leg_r_type: FeatureChoiced = {
  name: 'Leg Right Type',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const leg_l_type: FeatureChoiced = {
  name: 'Leg Left Type',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

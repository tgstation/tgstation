import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const head_type: FeatureChoiced = {
  name: 'Add Limb: Head',
  description: `
  Add a cybernetic head to your character, this option is exclusive to this species.
`,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const chest_type: FeatureChoiced = {
  name: 'Add Limb: Chest',
  description: `
  Add a cybernetic chassis to your character.
`,
  component: FeatureDropdownInput,
};

export const markings_head: FeatureChoiced = {
  name: 'Head Markings',
  description: `
  Add a suitable marking to your character's head.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const arm_r_type: FeatureChoiced = {
  name: 'Add Limb: R-Arm',
  description: `
  Add a cybernetic arm to your character.
`,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const arm_l_type: FeatureChoiced = {
  name: 'Add Limb: L-Arm',
  description: `
  Add a cybernetic arm to your character.
`,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const leg_r_type: FeatureChoiced = {
  name: 'Add Limb: R-Leg',
  description: `
  Add a cybernetic leg to your character.
`,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const leg_l_type: FeatureChoiced = {
  name: 'Add Limb: L-Leg',
  description: `
  Add a cybernetic leg to your character.
`,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

import {
  Feature,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureColorInput,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const markings_head: FeatureChoiced = {
  name: 'a. Head Markings',
  description: `
  Add a suitable marking to your character's head.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_head_color: Feature<string> = {
  name: 'aa. Head Markings Color',
  component: FeatureColorInput,
};

export const markings_head2: FeatureChoiced = {
  name: 'b. Head Markings 2',
  description: `
  Add a suitable marking to your character's head.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_head_color2: Feature<string> = {
  name: 'bb. Head Markings Color 2',
  component: FeatureColorInput,
};

export const markings_head3: FeatureChoiced = {
  name: 'c. Head Markings 3',
  description: `
  Add a suitable marking to your character's head.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_head_color3: Feature<string> = {
  name: 'cc. Head Markings Color 3',
  component: FeatureColorInput,
};

export const markings_chest: FeatureChoiced = {
  name: 'd. Chest Markings',
  description: `
  Add a suitable marking to your character's chest.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_chest_color: Feature<string> = {
  name: 'dd. Chest Markings Color',
  component: FeatureColorInput,
};

export const markings_chest2: FeatureChoiced = {
  name: 'e. Chest Markings 2',
  description: `
  Add a suitable marking to your character's chest.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_chest_color2: Feature<string> = {
  name: 'ee. Chest Markings Color 2',
  component: FeatureColorInput,
};

export const markings_chest3: FeatureChoiced = {
  name: 'f. Chest Markings 3',
  description: `
  Add a suitable marking to your character's chest.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_chest_color3: Feature<string> = {
  name: 'ff. Chest Markings Color 3',
  component: FeatureColorInput,
};

export const markings_r_arm: FeatureChoiced = {
  name: 'g. Right Arm Markings',
  description: `
  Add a suitable marking to your character's right arm.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_arm_color: Feature<string> = {
  name: 'gg. Right Arm Markings Color',
  component: FeatureColorInput,
};

export const markings_r_arm2: FeatureChoiced = {
  name: 'h. Right Arm Markings 2',
  description: `
  Add a suitable marking to your character's right arm.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_arm_color2: Feature<string> = {
  name: 'hh. Rig Arm Markings Color 2',
  component: FeatureColorInput,
};

export const markings_r_arm3: FeatureChoiced = {
  name: 'i. Right Arm Markings 3',
  description: `
  Add a suitable marking to your character's right arm.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_arm_color3: Feature<string> = {
  name: 'ii. Right Arm Markings Color 3',
  component: FeatureColorInput,
};

export const markings_l_arm: FeatureChoiced = {
  name: 'j. Left Arm Markings',
  description: `
  Add a suitable marking to your character's left arm.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_arm_color: Feature<string> = {
  name: 'jj. Left Arm Markings Color',
  component: FeatureColorInput,
};

export const markings_l_arm2: FeatureChoiced = {
  name: 'k. Left Arm Markings 2',
  description: `
  Add a suitable marking to your character's left arm.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_arm_color2: Feature<string> = {
  name: 'kk. Left Arm Markings Color 2',
  component: FeatureColorInput,
};

export const markings_l_arm3: FeatureChoiced = {
  name: 'l. Left Arm Markings 3',
  description: `
  Add a suitable marking to your character's l_arm.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_arm_color3: Feature<string> = {
  name: 'll. Left Arm Markings Color 3',
  component: FeatureColorInput,
};

export const markings_l_hand: FeatureChoiced = {
  name: 'm. Left Hand Markings',
  description: `
  Add a suitable marking to your character's left hand.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_hand_color: Feature<string> = {
  name: 'mm. Left Hand Markings Color',
  component: FeatureColorInput,
};

export const markings_l_hand2: FeatureChoiced = {
  name: 'n. Left Hand Markings 2',
  description: `
  Add a suitable marking to your character's left hand.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_hand_color2: Feature<string> = {
  name: 'nn. Left Hand Markings Color 2',
  component: FeatureColorInput,
};

export const markings_l_hand3: FeatureChoiced = {
  name: 'o. Left Hand Markings 3',
  description: `
  Add a suitable marking to your character's left hand.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_hand_color3: Feature<string> = {
  name: 'oo. Left Hand Markings Color 3',
  component: FeatureColorInput,
};

export const markings_r_hand: FeatureChoiced = {
  name: 'p. Right Hand Markings',
  description: `
  Add a suitable marking to your character's right hand.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_hand_color: Feature<string> = {
  name: 'pp. Right Hand Markings Color',
  component: FeatureColorInput,
};

export const markings_r_hand2: FeatureChoiced = {
  name: 'q. Right Hand Markings 2',
  description: `
  Add a suitable marking to your character's right hand.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_hand_color2: Feature<string> = {
  name: 'qq. Right Hand Markings Color 2',
  component: FeatureColorInput,
};

export const markings_r_hand3: FeatureChoiced = {
  name: 'r. Right Hand Markings 3',
  description: `
  Add a suitable marking to your character's right hand.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_hand_color3: Feature<string> = {
  name: 'rr. Right Hand Markings Color 3',
  component: FeatureColorInput,
};

export const markings_l_leg: FeatureChoiced = {
  name: 's. Left Leg Markings',
  description: `
  Add a suitable marking to your character's left leg.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_leg_color: Feature<string> = {
  name: 'ss. Left Leg Markings Color',
  component: FeatureColorInput,
};

export const markings_l_leg2: FeatureChoiced = {
  name: 't. Left Leg Markings 2',
  description: `
  Add a suitable marking to your character's left leg.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_leg_color2: Feature<string> = {
  name: 'tt. Left Leg Markings Color 2',
  component: FeatureColorInput,
};

export const markings_l_leg3: FeatureChoiced = {
  name: 'u. Left Leg Markings 3',
  description: `
  Add a suitable marking to your character's left leg.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_l_leg_color3: Feature<string> = {
  name: 'uu. Left Leg Markings Color 3',
  component: FeatureColorInput,
};

export const markings_r_leg: FeatureChoiced = {
  name: 'v. Right Leg Markings',
  description: `
  Add a suitable marking to your character's right leg.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_leg_color: Feature<string> = {
  name: 'vv. Right Leg Markings Color',
  component: FeatureColorInput,
};

export const markings_r_leg2: FeatureChoiced = {
  name: 'w. Right Leg Markings 2',
  description: `
  Add a suitable marking to your character's right leg.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_leg_color2: Feature<string> = {
  name: 'ww. Right Leg Markings Color 2',
  component: FeatureColorInput,
};

export const markings_r_leg3: FeatureChoiced = {
  name: 'x. Right Leg Markings 3',
  description: `
  Add a suitable marking to your character's right leg.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const markings_r_leg_color3: Feature<string> = {
  name: 'xx. Right Leg Markings Color 3',
  component: FeatureColorInput,
};

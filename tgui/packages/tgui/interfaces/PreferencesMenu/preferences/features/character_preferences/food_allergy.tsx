import { FeatureChoiced, FeatureDropdownInput } from '../base';

export const food_allergy: FeatureChoiced = {
  name: 'Food Allergy',
  description:
    'The food type you are allergic to. Note that alcoholic drinks do NOT count as alcohol.',
  component: FeatureDropdownInput,
};

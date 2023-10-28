import { FeatureChoiced, FeatureDropdownInput } from '../base';

export const language: FeatureChoiced = {
  name: 'Language',
  description:
    "The extra language you know. Note that if you already know the language, you'll be given galactic uncommon instead.",
  component: FeatureDropdownInput,
};

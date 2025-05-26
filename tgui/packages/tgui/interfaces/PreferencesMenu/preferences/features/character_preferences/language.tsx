import { CheckboxInput, FeatureChoiced, FeatureToggle } from '../base';
import {
  FeatureDropdownInput,
  FeatureIconnedDropdownInput,
} from '../dropdowns';

export const language: FeatureChoiced = {
  name: 'Language',
  component: FeatureIconnedDropdownInput,
};

export const language_speakable: FeatureToggle = {
  name: 'Language Speakable',
  description: `If unchecked, you'll only be able to understand the language,
    but not speak it.`,
  component: CheckboxInput,
};

export const language_skill: FeatureChoiced = {
  name: 'Language Skill',
  description: 'The percentage of the language you can understand.',
  component: FeatureDropdownInput,
};

export const csl_strength: FeatureChoiced = {
  name: 'Language Skill',
  description: 'The percentage of Common you can understand.',
  component: FeatureDropdownInput,
};

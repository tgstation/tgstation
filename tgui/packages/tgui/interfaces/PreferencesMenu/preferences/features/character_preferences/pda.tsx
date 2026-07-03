import {
  type Feature,
  type FeatureChoiced,
  FeatureShortTextInput,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const pda_theme: FeatureChoiced = {
  name: 'КПК: тема',
  category: 'GAMEPLAY',
  component: FeatureDropdownInput,
};

export const pda_ringtone: Feature<string> = {
  name: 'КПК: рингтон',
  component: FeatureShortTextInput,
};

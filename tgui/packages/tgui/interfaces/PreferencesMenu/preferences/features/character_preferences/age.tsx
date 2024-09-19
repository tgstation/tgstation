import { Feature, FeatureNumberInput } from '../base';

export const age: Feature<number> = {
  name: 'Age',
  description: "The effective and actual age of your character expressed in years. If they haven't entered cryostasis for any meaningful length of time or are otherwise uncommonly long-lived, this number is their age in years since birth.",
  component: FeatureNumberInput,
};

import { type Feature, FeatureSliderInput } from '../base';

export const emissive_bloom: Feature<number> = {
  name: 'Emissive Bloom Strength',
  category: 'GAMEPLAY',
  description: `How strong the bloom on emissive objects, such as computer screens, is. This has negligible performance impact.`,
  component: FeatureSliderInput,
};

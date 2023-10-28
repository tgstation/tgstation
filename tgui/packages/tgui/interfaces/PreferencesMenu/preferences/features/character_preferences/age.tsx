import { Feature, FeatureNumberInput } from '../base';

export const age: Feature<number> = {
  name: 'Age',
  description:
    'Note that a age below 21 will mark you as a minor and prevent alcohol vendors from selling to you, \
    and <18 prevents cigarette vendors from selling.',
  component: FeatureNumberInput,
};

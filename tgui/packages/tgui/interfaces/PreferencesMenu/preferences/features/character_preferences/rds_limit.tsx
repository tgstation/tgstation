import { CheckboxInput, FeatureToggle } from '../base';

export const rds_limit: FeatureToggle = {
  name: 'Unlimit Hallucinations',
  description:
    'Checking this box will remove limitations on hallucinations, \
    causing them to be more frequent, intrusive, and (generally) wacky.',
  component: CheckboxInput,
};

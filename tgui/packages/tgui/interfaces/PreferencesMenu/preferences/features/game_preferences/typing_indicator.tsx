import { CheckboxInput, FeatureToggle } from '../base';

export const typingIndicator: FeatureToggle = {
  name: 'Enable typing indicators for self',
  category: 'GAMEPLAY',
  description: "Enable typing indicators that show you're typing a message.",
  component: CheckboxInput,
};

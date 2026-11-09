import { CheckboxInput, type FeatureToggle } from '../base';

export const disable_lobby_transparency: FeatureToggle = {
  name: 'Disable Lobby-menu Transparency',
  category: 'UI',
  description: 'Prevent admins from making the lobby screen transparent.',
  component: CheckboxInput,
};

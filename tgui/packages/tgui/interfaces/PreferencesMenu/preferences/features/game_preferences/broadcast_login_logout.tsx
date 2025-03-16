import { CheckboxInput, FeatureToggle } from '../base';

export const broadcast_login_logout: FeatureToggle = {
  name: 'Транслировать login/logout',
  category: 'Гемплей',
  description: `
    Когда эта функция включена, при отключении и повторном подключении в deadchat будет отправлено уведомление.
  `,
  component: CheckboxInput,
};

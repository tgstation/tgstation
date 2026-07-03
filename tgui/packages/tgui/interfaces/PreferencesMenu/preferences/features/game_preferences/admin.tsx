import {
  CheckboxInput,
  type Feature,
  FeatureColorInput,
  type FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const asaycolor: Feature<string> = {
  name: 'Цвет админских сообщений',
  category: 'Админ',
  description: 'Цвет ваших сообщений в админском и менторском чатах.',
  component: FeatureColorInput,
};

export const brief_outfit: Feature<string> = {
  name: 'Экипировка для брифинга',
  category: 'Админ',
  description: 'Экипировка, выдаваемая вам на роли брифинг офицера.',
  component: FeatureDropdownInput,
};

export const bypass_deadmin_in_centcom: FeatureToggle = {
  name: 'Игнорировать deadmin при спавне на ЦК',
  category: 'Админ',
  description:
    'Оставаться ли с правами администратора, когда вы появляетесь на ЦК.',
  component: CheckboxInput,
};

export const fast_mc_refresh: FeatureToggle = {
  name: 'Включить ускоренное обновление MC',
  category: 'Админ',
  description:
    'Должна ли панель MC со стат-панели обновляться быстрее обычного. Используйте, только если она нужна!',
  component: CheckboxInput,
};

export const ghost_roles_as_admin: FeatureToggle = {
  name: 'Получать гост-роли будучи админом',
  category: 'Админ',
  description: `
    Если вы отключите это, то вы не будете получать предложения о гост-ролях,
    когда вы с правами администратора. НИКАКОЕ оповещение не будет повляться для вас.
    Но эта опция ничего не делает, если вы являетесь обычным игроком
    (deadmin).
`,
  component: CheckboxInput,
};

export const comms_notification: FeatureToggle = {
  name: 'Звуковое оповещение о факсах на ЦК',
  category: 'Админ',
  component: CheckboxInput,
};

export const auto_deadmin_on_ready_or_latejoin: FeatureToggle = {
  name: 'Авто deadmin - Готов или Лейтджоин',
  category: 'Админ',
  description: `
    When enabled, you will automatically deadmin when you click to ready up or latejoin a round.
`,
  component: CheckboxInput,
};

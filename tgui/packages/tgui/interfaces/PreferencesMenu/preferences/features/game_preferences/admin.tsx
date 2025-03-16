import {
  CheckboxInput,
  Feature,
  FeatureColorInput,
  FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const asaycolor: Feature<string> = {
  name: 'Цвет чата администрации',
  category: 'Админ',
  description: 'Цвет ваших сообщений в Adminsay.',
  component: FeatureColorInput,
};

export const brief_outfit: Feature<string> = {
  name: 'Экипировка',
  category: 'Админ',
  description:
    'Экипировка, которую можно получить при появлении в качестве офицера-инструктора.',
  component: FeatureDropdownInput,
};

export const bypass_deadmin_in_centcom: FeatureToggle = {
  name: 'Обходите настройки deadmin на ЦентКом',
  category: 'Админ',
  description:
    'Следует ли всегда оставаться администратором при появлении на ЦентКом или нет.',
  component: CheckboxInput,
};

export const fast_mc_refresh: FeatureToggle = {
  name: 'Быстрое обновление статистики MC',
  category: 'Админ',
  description:
    'Независимо от того, быстро ли обновляется вкладка MC на панели статистики. Это дорого, поэтому убедитесь, что вам это нужно.',
  component: CheckboxInput,
};

export const ghost_roles_as_admin: FeatureToggle = {
  name: 'Получайте призрачные роли во время администрирования',
  category: 'Админ',
  description: `
    Если вы отключите этот параметр, у вас не будет всплывающих окон с ролями-призраками, пока
    вы являетесь администратором! Ни одно всплывающее окно не будет отображаться для вас в
    режиме администратора. Однако это не отключает уведомления, если вы являетесь
    обычным игроком (deadmin).
`,
  component: CheckboxInput,
};

export const comms_notification: FeatureToggle = {
  name: 'Включить звук консоли связи',
  category: 'Админ',
  component: CheckboxInput,
};

export const auto_deadmin_on_ready_or_latejoin: FeatureToggle = {
  name: 'Автоматическое отключение - Готовность или позднее подключение',
  category: 'Админ',
  description: `
    Если эта функция включена, вы автоматически отключаете время ожидания,
    когда нажимаете кнопку "Готово" или "поздно присоединиться к раунду".
`,
  component: CheckboxInput,
};

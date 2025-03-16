import { CheckboxInput, CheckboxInputInverse, FeatureToggle } from '../base';

export const admin_ignore_cult_ghost: FeatureToggle = {
  name: 'Предотвратите вызов в качестве культового призрака',
  category: 'Админ',
  description: `
    При включении и наблюдении не позволяет Царству духов превратить вас
    в культового призрака.
  `,
  component: CheckboxInput,
};

export const announce_login: FeatureToggle = {
  name: 'Объявить о входе в систему',
  category: 'Админ',
  description: 'Администраторы будут уведомлены, когда вы войдете в систему.',
  component: CheckboxInput,
};

export const combohud_lighting: FeatureToggle = {
  name: 'Включить комбинированный дисплей HUD',
  category: 'Админ',
  component: CheckboxInput,
};

export const deadmin_always: FeatureToggle = {
  name: 'Автоматически deadmin - Всегда',
  category: 'Админ',
  description:
    'Когда эта функция включена, вы автоматически становитесь в deadmin.',
  component: CheckboxInput,
};

export const deadmin_antagonist: FeatureToggle = {
  name: 'Автоматически deadmin - Антагонист',
  category: 'Админ',
  description:
    'Когда эта функция включена, вы автоматически становитесь в deadmin.',
  component: CheckboxInput,
};

export const deadmin_position_head: FeatureToggle = {
  name: 'Автоматически deadmin - Руководитель отдела',
  category: 'Админ',
  description:
    'Когда эта функция включена, вы автоматически становитесь в deadmin.',
  component: CheckboxInput,
};

export const deadmin_position_security: FeatureToggle = {
  name: 'Автоматически deadmin - Бриг',
  category: 'Админ',
  description:
    'Когда эта функция включена, вы автоматически становитесь в deadmin.',
  component: CheckboxInput,
};

export const deadmin_position_silicon: FeatureToggle = {
  name: 'Автоматически deadmin - ИИ и киборги',
  category: 'Админ',
  description:
    'Когда эта функция включена, вы автоматически становитесь в deadmin.',
  component: CheckboxInput,
};

export const disable_arrivalrattle: FeatureToggle = {
  name: 'Уведомлять о новых ролях',
  category: 'Призрак',
  description:
    'Когда это будет включено, вы будете уведомлены как призрак о появлении новой роли.',
  component: CheckboxInputInverse,
};

export const disable_deathrattle: FeatureToggle = {
  name: 'Уведомлять о смертельных случаях',
  category: 'Призрак',
  description:
    'Если эта функция включена, вы будете получать уведомления как призрак всякий раз, когда кто-то умрет.',
  component: CheckboxInputInverse,
};

export const member_public: FeatureToggle = {
  name: 'Обнародовать членство в BYOND',
  category: 'Чат',
  description:
    'Если эта функция включена, рядом с вашим именем в OOC будет отображаться логотип BYOND.',
  component: CheckboxInput,
};

export const sound_adminhelp: FeatureToggle = {
  name: 'Включить звуки ахелпа',
  category: 'Админ',
  component: CheckboxInput,
};

export const sound_prayers: FeatureToggle = {
  name: 'Включить звук молитвы',
  category: 'Админ',
  component: CheckboxInput,
};

export const split_admin_tabs: FeatureToggle = {
  name: 'Разделенные вкладки администратора',
  category: 'Админ',
  description:
    'При включении панель Администрирование будет разделена на несколько вкладок.',
  component: CheckboxInput,
};

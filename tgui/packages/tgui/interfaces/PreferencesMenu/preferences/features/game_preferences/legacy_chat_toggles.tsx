import { CheckboxInput, FeatureToggle } from '../base';

export const chat_bankcard: FeatureToggle = {
  name: 'Включить обновление зарплаты',
  category: 'Чат',
  description: 'Получайте уведомления на свой банковский счет.',
  component: CheckboxInput,
};

export const chat_dead: FeatureToggle = {
  name: 'Включить deadchat',
  category: 'Админ',
  component: CheckboxInput,
};

export const chat_ghostears: FeatureToggle = {
  name: 'Прослушивать все сообщения',
  category: 'Призрак',
  description: `
    Если эта функция включена, вы сможете слышать всю речь в режиме реального времени.
    Если она отключена, вы сможете слышать речь только поблизости.
  `,
  component: CheckboxInput,
};

export const chat_ghostlaws: FeatureToggle = {
  name: 'Включить обновление изменений в законодательстве',
  category: 'Призрак',
  description:
    'Если эта функция включена, получайте уведомления о любых новых изменениях в законодательстве в качестве призрака.',
  component: CheckboxInput,
};

export const chat_ghostpda: FeatureToggle = {
  name: 'Включить уведомления на ПДА',
  category: 'Призрак',
  description:
    'Если эта функция включена, вы будете получать уведомления о любых сообщениях (других игроков) с ПДА в виде призрака.',
  component: CheckboxInput,
};

export const chat_ghostradio: FeatureToggle = {
  name: 'Включить радио',
  category: 'Призрак',
  description:
    'Если эта функция включена, вы будете получать уведомления о любых радиосообщениях в виде призрака.',
  component: CheckboxInput,
};

export const chat_ghostsight: FeatureToggle = {
  name: 'Видеть все эмоции',
  category: 'Призрак',
  description:
    'Когда этот параметр включен, все эмоции отображаются в виде призрака.',
  component: CheckboxInput,
};

export const chat_ghostwhisper: FeatureToggle = {
  name: 'Видеть все перешептывания',
  category: 'Призрак',
  description: `
    Если эта функция включена, вы сможете слышать все перешептывания в качестве призрака.
    Если она отключена, вы сможете слышать только шепот поблизости.
  `,
  component: CheckboxInput,
};

export const chat_login_logout: FeatureToggle = {
  name: 'Видеть login/logout сообщения',
  category: 'Призрак',
  description:
    'Если эта функция включена, получайте уведомления, когда игрок входит в систему или выходит из нее.',
  component: CheckboxInput,
};

export const chat_ooc: FeatureToggle = {
  name: 'Включить OOC',
  category: 'Чат',
  component: CheckboxInput,
};

export const chat_prayer: FeatureToggle = {
  name: 'Слушайте молитвы',
  category: 'Админ',
  component: CheckboxInput,
};

export const chat_pullr: FeatureToggle = {
  name: 'Включить уведомления о запросах на извлечение',
  category: 'Чат',
  description:
    'Получать уведомления о выполнении запроса на извлечение, закрытии или объединении.',
  component: CheckboxInput,
};

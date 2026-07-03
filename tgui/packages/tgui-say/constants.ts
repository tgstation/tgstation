/** Window sizes in pixels */
export enum WindowSize {
  Small = 30,
  Medium = 50,
  Large = 68,
  Width = 325,
}

/** Line lengths for autoexpand */
export enum LineLength {
  Small = 30,
  Medium = 60,
  Large = 90,
}

/**
 * Radio prefixes.
 * Displays the name in the left button, tags a css class.
 */
export const RADIO_PREFIXES = {
  ':a ': 'Рой',
  ':b ': 'Бин',
  ':c ': 'Ком',
  ':e ': 'Инж',
  ':g ': 'Генка',
  ':m ': 'Мед',
  ':n ': 'Иссл',
  ':o ': 'ИИ',
  ':p ': 'Развл',
  ':s ': 'Безоп',
  ':l ': 'Юр',
  ':t ': 'Синд',
  ':u ': 'Снаб',
  ':v ': 'Обсл',
  ':y ': 'ЦК',

  ':ф ': 'Рой',
  ':и ': 'Бин',
  ':с ': 'Ком',
  ':у ': 'Инж',
  ':п ': 'Генка',
  ':ь ': 'Мед',
  ':т ': 'Иссл',
  ':щ ': 'ИИ',
  ':з ': 'Развл',
  ':ы ': 'Безоп',
  ':д ': 'Юр',
  ':е ': 'Синд',
  ':г ': 'Снаб',
  ':м ': 'Обсл',
  ':н ': 'ЦК',
} as const;

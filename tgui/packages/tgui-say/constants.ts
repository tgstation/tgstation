/** Window sizes in pixels */
export enum WINDOW_SIZES {
  small = 30,
  medium = 50,
  large = 70,
  width = 231,
}

/** Line lengths for autoexpand */
export enum LINE_LENGTHS {
  small = 22,
  medium = 45,
}

/**
 * Radio prefixes.
 * Displays the name in the left button, tags a css class.
 */
export const RADIO_PREFIXES = {
  ':a ': 'Hive',
  ':ф ': 'Hive',
  ':b ': 'io',
  ':и ': 'io',
  ':c ': 'Cmd',
  ':с ': 'Cmd',
  ':e ': 'Engi',
  ':у ': 'Engi',
  ':m ': 'Med',
  ':ь ': 'Med',
  ':n ': 'Sci',
  ':т ': 'Sci',
  ':o ': 'AI',
  ':щ ': 'AI',
  ':s ': 'Sec',
  ':ы ': 'Sec',
  ':t ': 'Synd',
  ':е ': 'Synd',
  ':u ': 'Supp',
  ':г ': 'Supp',
  ':v ': 'Svc',
  ':м ': 'Svc',
  ':y ': 'CCom',
  ':н ': 'CCom',
} as const;

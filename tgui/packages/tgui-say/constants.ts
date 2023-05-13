/** Window sizes in pixels */
export enum WINDOW_SIZES {
  small = 30,
  medium = 50,
  large = 70,
  width = 231,
}

/** Line lengths for autoexpand */
export enum LINE_LENGTHS {
  small = 20,
  medium = 35,
}

/**
 * Radio prefixes.
 * Displays the name in the left button, tags a css class.
 */
export const RADIO_PREFIXES = {
  ':a ': 'Hive',
  ':b ': 'Sili',
  ':c ': 'Cmd',
  ':e ': 'Engi',
  ':m ': 'Med',
  ':n ': 'Sci',
  ':o ': 'AI',
  ':s ': 'Sec',
  ':t ': 'Synd',
  ':u ': 'Supp',
  ':v ': 'Svc',
  ':y ': 'CCom',
} as const;

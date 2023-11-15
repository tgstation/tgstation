/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const SI_SYMBOLS = [
  'f', // femto
  'p', // pico
  'n', // nano
  'μ', // micro
  'm', // milli
  // NOTE: This is a space for a reason. When we right align si numbers,
  // in monospace mode, we want to units and numbers stay in their respective
  // columns. If rendering in HTML mode, this space will collapse into
  // a single space anyway.
  ' ', // base
  'k', // kilo
  'M', // mega
  'G', // giga
  'T', // tera
  'P', // peta
  'E', // exa
  'Z', // zetta
  'Y', // yotta
  'R', // ronna
  'Q', // quecca
  'F',
  'N',
  'H',
] as const;

const SI_BASE_INDEX = SI_SYMBOLS.indexOf(' ');

// Formats a number to a human readable form, with a custom unit
export const formatSiUnit = (
  value: number,
  minBase1000 = -SI_BASE_INDEX,
  unit = ''
): string => {
  if (!isFinite(value)) {
    return value.toString();
  }

  const realBase10 = Math.floor(Math.log10(Math.abs(value)));
  const base10 = Math.max(minBase1000 * 3, realBase10);
  const base1000 = Math.floor(base10 / 3);
  const symbol =
    SI_SYMBOLS[Math.min(base1000 + SI_BASE_INDEX, SI_SYMBOLS.length - 1)];

  const scaledValue = value / Math.pow(1000, base1000);

  let formattedValue = scaledValue.toFixed(2);
  if (formattedValue.endsWith('.00')) {
    formattedValue = formattedValue.slice(0, -3);
  } else if (formattedValue.endsWith('.0')) {
    formattedValue = formattedValue.slice(0, -2);
  }

  return `${formattedValue} ${symbol.trim()}${unit}`.trim();
};

// Formats a number to a human readable form, with power (W) as the unit
export const formatPower = (value: number, minBase1000 = 0) => {
  return formatSiUnit(value, minBase1000, 'W');
};

// Formats a number as a currency string
export const formatMoney = (value: number, precision = 0) => {
  if (!Number.isFinite(value)) {
    return String(value);
  }

  // Round the number and make it fixed precision
  const roundedValue = Number(value.toFixed(precision));

  // Handle the negative sign
  const isNegative = roundedValue < 0;
  const absoluteValue = Math.abs(roundedValue);

  // Convert to string and place thousand separators
  const parts = absoluteValue.toString().split('.');
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, '\u2009'); // Thin space

  const formattedValue = parts.join('.');

  return isNegative ? `-${formattedValue}` : formattedValue;
};

// Formats a floating point number as a number on the decibel scale
export const formatDb = (value: number) => {
  const db = 20 * Math.log10(value);
  const sign = db >= 0 ? '+' : '-';
  let formatted: string | number = Math.abs(db);

  if (formatted === Infinity) {
    formatted = 'Inf';
  } else {
    formatted = formatted.toFixed(2);
  }

  return `${sign}${formatted} dB`;
};

const SI_BASE_TEN_UNITS = [
  '',
  '· 10³', // kilo
  '· 10⁶', // mega
  '· 10⁹', // giga
  '· 10¹²', // tera
  '· 10¹⁵', // peta
  '· 10¹⁸', // exa
  '· 10²¹', // zetta
  '· 10²⁴', // yotta
  '· 10²⁷', // ronna
  '· 10³⁰', // quecca
  '· 10³³',
  '· 10³⁶',
  '· 10³⁹',
] as const;

// Converts a number to a string with SI base 10 units
export const formatSiBaseTenUnit = (
  value: number,
  minBase1000 = 0,
  unit = ''
): string => {
  if (!isFinite(value)) {
    return 'NaN';
  }

  const realBase10 = Math.floor(Math.log10(value));
  const base10 = Math.max(minBase1000 * 3, realBase10);
  const base1000 = Math.floor(base10 / 3);
  const symbol = SI_BASE_TEN_UNITS[base1000];

  const scaledValue = value / Math.pow(1000, base1000);
  const precision = Math.max(0, 2 - (base10 % 3));
  const formattedValue = scaledValue.toFixed(precision);

  return `${formattedValue} ${symbol} ${unit}`.trim();
};

/**
 * Formats decisecond count into HH:MM:SS display by default
 * "short" format does not pad and adds hms suffixes
 */
export const formatTime = (
  val: number,
  formatType: 'short' | 'default' = 'default'
): string => {
  const totalSeconds = Math.floor(val / 10);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (formatType === 'short') {
    const hoursFormatted = hours > 0 ? `${hours}h` : '';
    const minutesFormatted = minutes > 0 ? `${minutes}m` : '';
    const secondsFormatted = seconds > 0 ? `${seconds}s` : '';
    return `${hoursFormatted}${minutesFormatted}${secondsFormatted}`;
  }

  const hoursPadded = String(hours).padStart(2, '0');
  const minutesPadded = String(minutes).padStart(2, '0');
  const secondsPadded = String(seconds).padStart(2, '0');

  return `${hoursPadded}:${minutesPadded}:${secondsPadded}`;
};

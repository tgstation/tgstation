/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp, round, toFixed } from 'common/math';

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
  ' ',
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

const SI_BASE_INDEX: number = SI_SYMBOLS.indexOf(' ');

// Formats a number to a human readable form, by reducing it to SI units
export const formatSiUnit = (
  value: number,
  minBase1000: number = -SI_BASE_INDEX,
  unit: string = ''
) => {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return value;
  }
  const realBase10 = Math.floor(Math.log10(value));
  const base10 = Math.floor(Math.max(minBase1000 * 3, realBase10));
  const realBase1000 = Math.floor(realBase10 / 3);
  const base1000 = Math.floor(base10 / 3);
  const symbolIndex = clamp(SI_BASE_INDEX + base1000, 0, SI_SYMBOLS.length);
  const symbol = SI_SYMBOLS[symbolIndex];
  const scaledNumber = value / Math.pow(1000, base1000);

  const scaledPrecision =
    realBase1000 > minBase1000 ? 2 + base1000 * 3 - base10 : 0;
  // TODO: Make numbers bigger than precision value show
  // up to 2 decimal numbers.

  const finalString =
    toFixed(scaledNumber, scaledPrecision) + ' ' + symbol + unit;
  return finalString.trim();
};

// Formats a number to a human readable form, with power (W) as the unit
export const formatPower = (value: number, minBase1000: number = 0) => {
  return formatSiUnit(value, minBase1000, 'W');
};

// Formats a number as a currency string
export const formatMoney = (value: number, precision: number = 0) => {
  if (!Number.isFinite(value)) {
    return value;
  }
  // Round the number and make it fixed precision
  let fixed = round(value, precision);
  if (precision > 0) {
    fixed = toFixed(value, precision);
  }
  fixed = String(fixed);
  // Place thousand separators
  const length = fixed.length;
  let indexOfPoint = fixed.indexOf('.');
  if (indexOfPoint === -1) {
    indexOfPoint = length;
  }
  let result = '';
  for (let i = 0; i < length; i++) {
    if (i > 0 && i < indexOfPoint && (indexOfPoint - i) % 3 === 0) {
      // Thin space
      result += '\u2009';
    }
    result += fixed.charAt(i);
  }
  return result;
};

// Formats a floating point number as a number on the decibel scale
export const formatDb = (value: number) => {
  const db = (20 * Math.log(value)) / Math.log(10);
  const sign = db >= 0 ? '+' : '–';
  const absolute = Math.abs(db);
  let formatted;
  if (absolute === Infinity) {
    formatted = 'Inf';
  } else {
    formatted = toFixed(formatted, 2);
  }
  return sign + formatted + ' dB';
};

const SI_BASE_TEN_UNIT = [
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

const SI_BASE_TEN_INDEX: number = SI_BASE_TEN_UNIT.indexOf('');

// Formats a number to a human readable form, by reducing it to SI units (base 10)
export const formatSiBaseTenUnit = (
  value: number,
  minBase1000: number = -SI_BASE_TEN_INDEX,
  unit: string = ''
) => {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return value;
  }
  const realBase10 = Math.floor(Math.log10(value));
  const base10 = Math.floor(Math.max(minBase1000 * 3, realBase10));
  const realBase1000 = Math.floor(realBase10 / 3);
  const base1000 = Math.floor(base10 / 3);
  const symbolIndex = clamp(
    SI_BASE_TEN_INDEX + base1000,
    0,
    SI_BASE_TEN_UNIT.length
  );
  const symbol = SI_BASE_TEN_UNIT[symbolIndex];
  const scaledNumber = value / Math.pow(1000, base1000);
  const scaledPrecision =
    realBase1000 > minBase1000 ? 2 + base1000 * 3 - base10 : 0;
  // TODO: Make numbers bigger than precision value show
  // up to 2 decimal numbers.

  const finalString =
    toFixed(scaledNumber, scaledPrecision) + ' ' + symbol + ' ' + unit;
  return finalString.trim();
};

/**
 * Formats decisecond count into HH:MM:SS display by default
 * "short" format does not pad and adds hms suffixes
 */
export const formatTime = (
  val: number,
  formatType: 'short' | 'default' = 'default'
): string => {
  const seconds = Math.floor((val / 10) % 60);
  const minutes = Math.floor((val / (10 * 60)) % 60);
  const hours = Math.floor((val / (10 * 60 * 60)) % 24);

  switch (formatType) {
    case 'short': {
      const hours_truncated = hours > 0 ? `${hours}h` : '';
      const minutes_truncated = minutes > 0 ? `${minutes}m` : '';
      const seconds_truncated = seconds > 0 ? `${seconds}s` : '';
      return `${hours_truncated}${minutes_truncated}${seconds_truncated}`;
    }
    default: {
      return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(
        2,
        '0'
      )}:${String(seconds).padStart(2, '0')}`;
    }
  }
};

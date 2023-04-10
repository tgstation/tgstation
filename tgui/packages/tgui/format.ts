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

const SI_BASE_INDEX = SI_SYMBOLS.indexOf(' ');

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
  const base1000 = Math.floor(base10 / 3);
  const symbolIndex = clamp(SI_BASE_INDEX + base1000, 0, SI_SYMBOLS.length);
  const symbol = SI_SYMBOLS[symbolIndex];
  const scaledNumber = value / Math.pow(1000, base1000);
  const scaledPrecision =
    realBase10 > minBase1000 * 3 ? 2 + base1000 * 3 - base10 : 0;

  return `${toFixed(scaledNumber, scaledPrecision)} ${symbol}${unit}`.trim();
};

// Formats a number to a human readable form, with power (W) as the unit
export const formatPower = (value: number, minBase1000 = 0) => {
  return formatSiUnit(value, minBase1000, 'W');
};

// Formats a number as a currency string
export const formatMoney = (value: number, precision = 0) => {
  if (!Number.isFinite(value)) {
    return value;
  }

  const fixed: string =
    precision > 0
      ? toFixed(value, precision)
      : round(value, precision).toString();
  const indexOfPoint = fixed.indexOf('.');

  // make an array of the letters in fixed
  return fixed
    .split('')
    .map((char, i) =>
      i > 0 && i < indexOfPoint && (indexOfPoint - i) % 3 === 0
        ? '\u2009' + char
        : char
    )
    .join('');
};

// Formats a floating point number as a number on the decibel scale
export const formatDb = (value: number) => {
  const db = (20 * Math.log(value)) / Math.log(10);
  const sign = db >= 0 ? '+' : '–';
  const absolute = Math.abs(db);
  const formatted = absolute === Infinity ? 'Inf' : toFixed(absolute, 2);

  return `${sign}${formatted} dB`;
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

const SI_BASE_TEN_INDEX = SI_BASE_TEN_UNIT.indexOf('');

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
  const base1000 = Math.floor(base10 / 3);
  const symbolIndex = clamp(
    SI_BASE_TEN_INDEX + base1000,
    0,
    SI_BASE_TEN_UNIT.length
  );
  const symbol = SI_BASE_TEN_UNIT[symbolIndex];
  const scaledNumber = value / Math.pow(1000, base1000);

  // Convert the scaledNumber to a number and then apply toFixed() on it
  const scaledNumberFixed = Number(scaledNumber.toFixed(2));

  const finalString = `${scaledNumberFixed} ${symbol} ${unit}`.trim();

  return finalString;
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

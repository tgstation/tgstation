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
];

const SI_BASE_INDEX = SI_SYMBOLS.indexOf(' ');


/**
 * Formats a number to a human readable form, by reducing it to SI units.
 * TODO: This is quite a shit code and shit math, needs optimization.
 */
export const formatSiUnit = (
  value,
  minBase1000 = -SI_BASE_INDEX,
  unit = ''
) => {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return value;
  }
  const realBase10 = Math.floor(Math.log10(value));
  const base10 = Math.floor(Math.max(minBase1000 * 3, realBase10));
  const realBase1000 = Math.floor(realBase10 / 3);
  const base1000 = Math.floor(base10 / 3);
  const symbolIndex = clamp(
    SI_BASE_INDEX + base1000,
    0,
    SI_SYMBOLS.length);
  const symbol = SI_SYMBOLS[symbolIndex];
  const scaledNumber = value / Math.pow(1000, base1000);
  const scaledPrecision = realBase1000 > minBase1000
    ? (2 + base1000 * 3 - base10)
    : 0;
  // TODO: Make numbers bigger than precision value show
  // up to 2 decimal numbers.
  const finalString = (
    toFixed(scaledNumber, scaledPrecision)
    + ' ' + symbol + unit
  );
  return finalString.trim();
};

export const formatPower = (value, minBase1000 = 0) => {
  return formatSiUnit(value, minBase1000, 'W');
};

export const formatMoney = (value, precision = 0) => {
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

/**
 * Formats a floating point number as a number on the decibel scale.
 */
export const formatDb = value => {
  const db = 20 * Math.log(value) / Math.log(10);
  const sign = db >= 0 ? '+' : '–';
  let formatted = Math.abs(db);
  if (formatted === Infinity) {
    formatted = 'Inf';
  }
  else {
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
];

const SI_BASE_TEN_INDEX = SI_BASE_TEN_UNIT.indexOf(' ');


/**
 * Formats a number to a human readable form, by reducing it to SI units.
 * TODO: This is quite a shit code and shit math, needs optimization.
 */
export const formatSiBaseTenUnit = (
  value,
  minBase1000 = -SI_BASE_TEN_INDEX,
  unit = ''
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
    SI_BASE_TEN_UNIT.length);
  const symbol = SI_BASE_TEN_UNIT[symbolIndex];
  const scaledNumber = value / Math.pow(1000, base1000);
  const scaledPrecision = realBase1000 > minBase1000
    ? (2 + base1000 * 3 - base10)
    : 0;
  // TODO: Make numbers bigger than precision value show
  // up to 2 decimal numbers.
  const finalString = (
    toFixed(scaledNumber, scaledPrecision)
    + ' ' + symbol + ' ' + unit
  );
  return finalString.trim();
};

/**
 * Formats decisecond count into HH::MM::SS display by default
 * "short" format does not pad and adds hms suffixes
 */
export const formatTime = (val, formatType) => {
  // THERE IS AS YET INSUFFICIENT DATA FOR A MEANINGFUL ANSWER
  // HH:MM:SS
  // 00:02:13
  const seconds = toFixed(Math.floor((val/10) % 60));
  const minutes = toFixed(Math.floor((val/(10*60)) % 60));
  const hours = toFixed(Math.floor((val/(10*60*60)) % 24));
  switch (formatType) {
    case "short": {
      const hours_truncated = hours > 0 ? `${hours}h` : "";
      const minutes_truncated = minutes > 0 ? `${minutes}m` : "";
      const seconds_truncated = seconds > 0 ? `${seconds}s` : "";
      return `${hours_truncated}${minutes_truncated}${seconds_truncated}`;
    }
    default: {
      const seconds_padded = seconds.padStart(2, "0");
      const minutes_padded = minutes.padStart(2, "0");
      const hours_padded = hours.padStart(2, "0");
      return `${hours_padded}:${minutes_padded}:${seconds_padded}`;
    }
  }
};

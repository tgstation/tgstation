import { clamp, toFixed } from 'common/math';

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
];

const SI_BASE_INDEX = SI_SYMBOLS.indexOf(' ');


/**
 * Formats a number to a human readable form, by reducing it to SI units.
 * TODO: This is quite a shit code and shit math, needs optimization.
 */
const formatSiUnit = (value, minBase1000 = -SI_BASE_INDEX, unit = '') => {
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

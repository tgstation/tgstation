import { formatDb, formatMoney, formatPower, formatSiBaseTenUnit, formatSiUnit, formatTime } from './format';

describe('formatting utilities', () => {
  it('formats SI units correctly', () => {
    expect(formatSiUnit(1234, -3, 'g')).toBe('1.23 kg');
    expect(formatSiUnit(0.00123, -3, 'g')).toBe('1.23 mg');
  });

  it('formats power correctly', () => {
    expect(formatPower(1234567)).toBe('1.23 MW');
  });

  it('formats a number as a currency string', () => {
    expect(formatMoney(1234)).toBe('1234');
    expect(formatMoney(1234.56)).toBe('1235');
    expect(formatMoney(1234.5678, 2)).toBe('1 234.57');
    expect(formatMoney(-1234.5678, 2)).toBe('-1 234.57');
    expect(formatMoney(NaN)).toBe('NaN');
    expect(formatMoney(Infinity)).toBe('Infinity');
  });

  it('formats decibels correctly', () => {
    expect(formatDb(0.1)).toBe('–20.00 dB');
    expect(formatDb(10)).toBe('+20.00 dB');
  });

  it('formats SI base ten units correctly', () => {
    expect(formatSiBaseTenUnit(123456789, -1)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -2)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -3)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -4)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -5)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -6)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -7)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -8)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -9)).toEqual('123.46 · 10⁶');
    expect(formatSiBaseTenUnit(123456789, -10)).toEqual('123.46 · 10⁶');
  });

  it('formats time correctly', () => {
    expect(formatTime(36000)).toBe('01:00:00');
    expect(formatTime(36610)).toBe('01:01:01');
    expect(formatTime(36610, 'short')).toBe('1h1m1s');
  });
});

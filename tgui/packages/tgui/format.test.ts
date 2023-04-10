import { formatDb, formatMoney, formatPower, formatSiBaseTenUnit, formatSiUnit, formatTime } from './format';

describe('SI Formatter', () => {
  test('formatSiUnit', () => {
    expect(formatSiUnit(1000)).toBe('1 k');
    expect(formatSiUnit(1500)).toBe('1.5 k');
    expect(formatSiUnit(1500000, -3, 'g')).toBe('1.5 Mg');
  });

  test('formatPower', () => {
    expect(formatPower(1000)).toBe('1 kW');
    expect(formatPower(1500)).toBe('1.5 kW');
    expect(formatPower(1500000, -3)).toBe('1.5 MW');
  });

  test('formatMoney', () => {
    expect(formatMoney(1000)).toBe('1\u20091\u2009000');
    expect(formatMoney(1500.5)).toBe('1\u200915\u200900.5');
  });

  test('formatDb', () => {
    expect(formatDb(1)).toBe('+0 dB');
    expect(formatDb(10)).toBe('+20 dB');
  });

  test('formatSiBaseTenUnit', () => {
    expect(formatSiBaseTenUnit(1000)).toBe('1 · 10³');
    expect(formatSiBaseTenUnit(1500)).toBe('1.5 · 10³');
    expect(formatSiBaseTenUnit(1500000, -3, 'g')).toBe('1.5 · 10⁶ g');
  });

  test('formatTime', () => {
    expect(formatTime(36000)).toBe('01:00:00');
    expect(formatTime(36610)).toBe('01:01:01');
    expect(formatTime(36610, 'short')).toBe('1h1m1s');
  });
});

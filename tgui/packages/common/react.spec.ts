/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from './react';

describe('classes', () => {
  test('empty', () => {
    expect(classes([])).toBe('');
  });

  test('result contains inputs', () => {
    const output = classes(['foo', 'bar', false, true, 0, 1, 'baz']);
    expect(output).toContain('foo');
    expect(output).toContain('bar');
    expect(output).toContain('baz');
  });
});

import { describe, it } from 'vitest';

import { sanitizeText } from './sanitize';

describe('sanitizeText', () => {
  it('should sanitize basic HTML input', ({ expect }) => {
    const input = '<b>Hello, world!</b><script>alert("hack")</script>';
    const expected = '<b>Hello, world!</b>';
    const result = sanitizeText(input);
    expect(result).toBe(expected);
  });

  it('should sanitize advanced HTML input when advHtml flag is true', ({
    expect,
  }) => {
    const input =
      '<b>Hello, world!</b><iframe src="https://example.com"></iframe>';
    const expected = '<b>Hello, world!</b>';
    const result = sanitizeText(input, true);
    expect(result).toBe(expected);
  });

  it('should allow specific HTML tags when tags array is provided', ({
    expect,
  }) => {
    const input = '<b>Hello, world!</b><span>Goodbye, world!</span>';
    const tags = ['b'];
    const expected = '<b>Hello, world!</b>Goodbye, world!';
    const result = sanitizeText(input, false, tags);
    expect(result).toBe(expected);
  });

  it('should allow advanced HTML tags when advTags array is provided and advHtml flag is true', ({
    expect,
  }) => {
    const input =
      '<b>Hello, world!</b><iframe src="https://example.com"></iframe>';
    const advTags = ['iframe'];
    const expected =
      '<b>Hello, world!</b><iframe src="https://example.com"></iframe>';
    const result = sanitizeText(input, true, undefined, undefined, advTags);
    expect(result).toBe(expected);
  });
});

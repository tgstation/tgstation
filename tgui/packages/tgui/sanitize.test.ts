import { advTag, defAttr, defTag, sanitizeText } from './sanitize';

describe('sanitizeText', () => {
  test('sanitizes and removes disallowed HTML tags', () => {
    const input = '<script>alert("XSS Attack!");</script><p>Some text</p>';
    const output = sanitizeText(input, false);
    expect(output).toBe('<p>Some text</p>');
  });

  test('allows advanced HTML tags when advHtml is true', () => {
    const input =
      '<img src="https://example.com/image.jpg" alt="Example Image" /><p>Some text</p>';
    const output = sanitizeText(input, true);
    expect(output).toBe(input);
  });

  test('removes advanced HTML tags when advHtml is false', () => {
    const input =
      '<img src="https://example.com/image.jpg" alt="Example Image" /><p>Some text</p>';
    const output = sanitizeText(input, false);
    expect(output).toBe('<p>Some text</p>');
  });

  test('allows custom allowed HTML tags', () => {
    const input = '<custom>Custom tag</custom><p>Some text</p>';
    const output = sanitizeText(input, false, ['custom', ...defTag]);
    expect(output).toBe(input);
  });

  test('forbids custom HTML attributes', () => {
    const input = '<p forbiddenAttribute="value">Some text</p>';
    const output = sanitizeText(input, false, undefined, [
      'forbiddenAttribute',
      ...defAttr,
    ]);
    expect(output).toBe('<p>Some text</p>');
  });

  test('allows custom advanced HTML tags when advHtml is true', () => {
    const input =
      '<customadvanced>Custom advanced tag</customadvanced><p>Some text</p>';
    const output = sanitizeText(input, true, undefined, undefined, [
      'customadvanced',
      ...advTag,
    ]);
    expect(output).toBe(input);
  });
});

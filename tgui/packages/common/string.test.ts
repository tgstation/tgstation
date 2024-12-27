import { createSearch, decodeHtmlEntities, toTitleCase } from './string';

describe('createSearch', () => {
  it('matches search terms correctly', () => {
    const search = createSearch('test', (obj: { value: string }) => obj.value);

    const obj1 = { value: 'This is a test string.' };
    const obj2 = { value: 'This is a different string.' };
    const obj3 = { value: 'This is a test string.' };

    const objects = [obj1, obj2, obj3];

    expect(objects.filter(search)).toEqual([obj1, obj3]);
  });
});

describe('toTitleCase', () => {
  it('converts strings to title case correctly', () => {
    expect(toTitleCase('hello world')).toBe('Hello World');
    expect(toTitleCase('HELLO WORLD')).toBe('Hello World');
    expect(toTitleCase('HeLLo wORLd')).toBe('Hello World');
    expect(toTitleCase('a tale of two cities')).toBe('A Tale of Two Cities');
    expect(toTitleCase('war and peace')).toBe('War and Peace');
  });
});

describe('decodeHtmlEntities', () => {
  it('decodes HTML entities and removes unnecessary HTML tags correctly', () => {
    expect(decodeHtmlEntities('<br>')).toBe('\n');
    expect(decodeHtmlEntities('<p>Hello World</p>')).toBe('Hello World');
    expect(decodeHtmlEntities('&amp;')).toBe('&');
    expect(decodeHtmlEntities('&#38;')).toBe('&');
    expect(decodeHtmlEntities('&#x26;')).toBe('&');
  });
});

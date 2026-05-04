import { describe, it } from 'bun:test';
import assert from 'node:assert/strict';
import * as z from 'zod';
import { smoothMerge } from './type-safety';

describe('smoothMerge', () => {
  it('merges valid fields from source into target', () => {
    const schema = z.object({
      a: z.string(),
      b: z.number(),
    });

    const source = { a: 'hello', b: 'not a number', c: true };
    const target = { a: 'default', b: 42 };

    const result = smoothMerge({ schema, source, target });
    assert.deepEqual(result, { a: 'hello', b: 42 });
  });

  it('returns target if source is empty', () => {
    const schema = z.object({
      a: z.string(),
    });

    const source = {};
    const target = { a: 'default' };
    const result = smoothMerge({ schema, source, target });
    assert.deepEqual(result, target);
  });

  it('completely ignores an object if its not in the schema', () => {
    const schema = z.object({
      a: z.string(),
      b: z.number(),
    });

    const source = {
      c: 1,
      d: [1, 2, 3],
    };

    const target = {
      a: 'default',
      b: 42,
    };

    const result = smoothMerge({ schema, source, target });
    assert.deepEqual(result, {
      a: 'default',
      b: 42,
    });
  });
});

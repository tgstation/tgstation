import type { ZodObject } from 'zod';

type MergeInput<TObj> = {
  /**
   * A zod object.
   * @see Writing a Zod Schema: https://zod.dev/basics
   */
  schema: ZodObject<any>;
  /** The input getting merged */
  source: Record<string, unknown>;
  /** The defaults, which is the shape of the output */
  target: TObj;
};

/**
 * Merges two objects together while validating the output against a zod schema.
 * Different than just parsing - it does not throw errors, it simply discards
 * invalid fields and invalid value types.
 *
 * @example
 *
 * ```ts
 * const schema = z.object({
 *   a: z.string(),
 *   b: z.number(),
 * });
 *
 * const source = { a: 'hello', b: 'not a number', c: true };
 * const target = { a: 'default', b: 42 };
 *
 * const result = smoothMerge({ schema, source, target });
 * // result is { a: 'hello', b: 42 }
 * ```
 */
export function smoothMerge<TObj extends Record<string, unknown>>(
  input: MergeInput<TObj>,
): TObj {
  if (Object.keys(input.source).length === 0) return input.target;

  const validated = {};

  for (const [key, value] of Object.entries(input.source)) {
    // Skip keys that are not in the schema
    if (!(key in input.schema.shape)) continue;

    const fieldSchema = input.schema.shape[key];
    const result = fieldSchema.safeParse(value);

    // Only assign fields which pass validation
    if (result.success) {
      validated[key] = result.data;
    }
  }

  return { ...input.target, ...validated };
}

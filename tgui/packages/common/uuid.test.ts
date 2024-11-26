import { createUuid } from './uuid';

describe('createUuid', () => {
  it('generates a UUID v4 string', () => {
    const uuid = createUuid();
    expect(uuid).toHaveLength(36);
    expect(uuid).toMatch(
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i,
    );
  });
});

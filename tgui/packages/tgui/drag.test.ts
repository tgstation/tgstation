import { getWindowPosition, getWindowSize, touchRecents } from './drag';

describe('drag', () => {
  describe('getWindowPosition', () => {
    it('returns window position as an array', () => {
      const position = getWindowPosition();
      expect(position).toHaveLength(2);
      expect(typeof position[0]).toBe('number');
      expect(typeof position[1]).toBe('number');
    });
  });

  describe('getWindowSize', () => {
    it('returns window size as an array', () => {
      const size = getWindowSize();
      expect(size).toHaveLength(2);
      expect(typeof size[0]).toBe('number');
      expect(typeof size[1]).toBe('number');
    });
  });

  describe('touchRecents', () => {
    it('updates recent items and limits the array length', () => {
      const recents = ['item1', 'item2', 'item3'];
      const [updatedRecents, trimmedItem] = touchRecents(recents, 'newItem', 3);
      expect(updatedRecents).toEqual(['newItem', 'item1', 'item2']);
      expect(trimmedItem).toBe('item3');
    });

    it('returns the same array if the touched item already exists', () => {
      const recents = ['item1', 'item2', 'item3'];
      const [updatedRecents, trimmedItem] = touchRecents(recents, 'item2', 3);
      expect(updatedRecents).toEqual(['item2', 'item1', 'item3']);
      expect(trimmedItem).toBeUndefined();
    });

    it('does not modify the array if the limit is not reached', () => {
      const recents = ['item1', 'item2', 'item3'];
      const [updatedRecents, trimmedItem] = touchRecents(recents, 'newItem', 5);
      expect(updatedRecents).toEqual(['newItem', 'item1', 'item2', 'item3']);
      expect(trimmedItem).toBeUndefined();
    });
  });
});

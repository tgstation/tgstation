/**
 * @file
 */
import { createUuid } from 'common/uuid';

export const createHighlightSetting = (obj) => ({
  id: createUuid(),
  highlightText: '',
  highlightColor: '#ffdd44',
  highlightWholeMessage: true,
  matchWord: false,
  matchCase: false,
  ...obj,
});

export const createDefaultHighlightSetting = (obj) =>
  createHighlightSetting({
    id: 'default',
    ...obj,
  });

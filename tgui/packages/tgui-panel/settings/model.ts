/**
 * @file
 */
import { createUuid } from 'common/uuid';

export const createHighlightSetting = (obj?: Record<string, any>) => ({
  id: createUuid(),
  highlightText: '',
  highlightColor: '#ffdd44',
  highlightWholeMessage: true,
  matchWord: false,
  matchCase: false,
  ...obj,
});

export const createDefaultHighlightSetting = (obj?: Record<string, any>) =>
  createHighlightSetting({
    id: 'default',
    ...obj,
  });

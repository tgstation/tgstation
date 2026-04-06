import { marked } from 'marked';
import { baseUrl } from 'marked-base-url';
import { markedSmartypants } from 'marked-smartypants';

import { sanitizeText } from './sanitize';

type ProcessedText = {
  __html: string;
};

export function processedText(value: string | null): ProcessedText {
  if (!value) {
    return { __html: '' };
  }

  const parsed = marked
    .use(
      {
        breaks: true,
      },
      markedSmartypants(),
      baseUrl('thisshouldbreakhttp'),
    )
    .parse(value, { async: false });

  const sanitized = sanitizeText(parsed);
  const textHtml = {
    __html:
      typeof sanitized === 'object' && sanitized !== null
        ? sanitized.sanitized
        : sanitized,
  };
  return textHtml;
}

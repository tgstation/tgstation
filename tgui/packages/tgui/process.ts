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

  const textHtml = {
    __html: sanitizeText(parsed),
  };
  return textHtml;
}

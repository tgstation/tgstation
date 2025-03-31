import { marked } from 'marked';

import { sanitizeText } from './sanitize';

export const processedText = (value) => {
  const textHtml = {
    __html: sanitizeText(
      marked(value, {
        breaks: true,
        smartypants: true,
        smartLists: true,
        baseUrl: 'thisshouldbreakhttp',
      }),
    ),
  };
  return textHtml;
};

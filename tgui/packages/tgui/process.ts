import { Marked } from 'marked';
import { markedSmartypants } from 'marked-smartypants';

import { sanitizeText } from './sanitize';

export const processedText = (value: string | null) => {
  if (!value) {
    return undefined;
  }
  const markedInstance = new Marked();
  markedInstance.use(
    {
      breaks: true,
    },
    markedSmartypants(),
  );
  return {
    __html: sanitizeText(markedInstance.parse(value) as string),
  };
};

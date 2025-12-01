import { InteractionType, type WritingImplement } from './types';

export function canEdit(heldItemDetails?: WritingImplement): boolean {
  if (!heldItemDetails) {
    return false;
  }

  return heldItemDetails.interaction_mode === InteractionType.writing;
}

type TokenizerReturn = {
  type: string;
  raw: string;
};

export function tokenizer(src: string): TokenizerReturn | undefined {
  const rule = /^\[_+\]/;
  const match = src.match(rule);
  if (match) {
    return {
      type: 'inputField',
      raw: match[0],
    };
  }
}

// Override function, any links and images should
// kill any other marked tokens we don't want here
export function walkTokens(token) {
  switch (token.type) {
    case 'url':
    case 'autolink':
    case 'reflink':
    case 'link':
    case 'image':
      token.type = 'text';
      // Once asset system is up change to some default image
      // or rewrite for icon images
      token.href = '';
      break;
  }
}

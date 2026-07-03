import {
  InteractionType,
  type PaperReplacement,
  type WriteButtonLocation,
  type WritingImplement,
} from './types';

const replacementRegex: RegExp = /\[(\w+)\]/gi;
export function canEdit(heldItemDetails?: WritingImplement): boolean {
  if (!heldItemDetails) {
    return false;
  }

  return heldItemDetails.interaction_mode === InteractionType.writing;
}

export function parseReplacements(
  text: string,
  replacements: PaperReplacement[] | undefined,
) {
  const list = Array.isArray(replacements) ? replacements : [];
  return text.replace(replacementRegex, (match, p1) => {
    return list.find((value) => p1 === value.key)?.value || match;
  });
}

export function tokenizer(src: string) {
  const rule = /^\[input_field\]/;
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

// Extracts the write button location from a full ID.
export function getWriteButtonLocation(id: string): WriteButtonLocation {
  const ids: string[] = id.replace('paperfield_', '').split('_');
  return { paperInputRef: `[${ids[0]}]`, fieldId: Number(ids[1]) };
}

// Builds a write button ID.
export function createWriteButtonId(
  paperInputRef: string,
  fieldId: number,
): string {
  return `paperfield_${paperInputRef.replaceAll(/[[\]]/g, '')}_${fieldId}`;
}

export function propRegex(propName: string) {
  return new RegExp(`${propName}=([a-zA-Z0-9]+)`, 'i');
}

export function blankPropRegex(propName: string) {
  return new RegExp(`${propName}\\s*=\\s*([^;\\]]+)(?:;|$)`, 'i');
}

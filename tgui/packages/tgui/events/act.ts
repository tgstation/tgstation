import { logger } from '../logging';
import { createQueue } from './handlers/chunking';

/**
 * Sends an action to `ui_act` on `src_object` that this tgui window
 * is associated with.
 */
export function sendAct(
  action: string,
  payload: Record<string, unknown> = {},
): void {
  // Validate that payload is an object
  const isObject =
    typeof payload === 'object' && payload !== null && !Array.isArray(payload);
  if (!isObject) {
    logger.error(`Payload for act() must be an object, got this:`, payload);
    return;
  }

  const stringifiedPayload = JSON.stringify(payload);
  const urlSize = Object.entries({
    type: `act/${action}`,
    payload: stringifiedPayload,
    tgui: 1,
    windowId: Byond.windowId,
  }).reduce(
    (url, [key, value], i) =>
      url +
      `${i > 0 ? '&' : '?'}${encodeURIComponent(key)}=${encodeURIComponent(value)}`,
    '',
  ).length;

  if (urlSize > 2048) {
    const chunks: string[] = stringifiedPayload.split(chunkSplitter);
    const id = `${Date.now()}`;
    createQueue({ id, chunks });
    Byond.sendMessage('oversizedPayloadRequest', {
      type: `act/${action}`,
      id,
      chunkCount: chunks.length,
    });
    return;
  }

  Byond.sendMessage(`act/${action}`, payload);
}

function encodedLengthBinarySearch(haystack: string[], length: number): number {
  const haystackLength = haystack.length;
  let high = haystackLength - 1;
  let low = 0;
  let mid = 0;

  while (low < high) {
    mid = Math.round((low + high) / 2);
    const substringLength = encodeURIComponent(
      haystack.slice(0, mid).join(''),
    ).length;
    if (substringLength === length) {
      break;
    }
    if (substringLength < length) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }

  return mid;
}

const chunkSplitter = {
  [Symbol.split]: (string: string) => {
    const charSeq = string[Symbol.iterator]().toArray();
    const length = charSeq.length;
    const chunks: string[] = [];
    let startIndex = 0;
    let endIndex = 1024;
    while (startIndex < length) {
      const cut = charSeq.slice(
        startIndex,
        endIndex < length ? endIndex : undefined,
      );
      const cutString = cut.join('');
      if (encodeURIComponent(cutString).length > 1024) {
        const splitIndex = startIndex + encodedLengthBinarySearch(cut, 1024);
        chunks.push(
          charSeq
            .slice(startIndex, splitIndex < length ? splitIndex : undefined)
            .join(''),
        );
        startIndex = splitIndex;
      } else {
        chunks.push(cutString);
        startIndex = endIndex;
      }
      endIndex = startIndex + 1024;
    }
    return chunks;
  },
};

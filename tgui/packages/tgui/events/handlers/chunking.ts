import { chunkingAtom, store } from '../store';

/// --------- Handlers ------------------------------------------------------///

type OversizePayload = {
  allow: boolean;
  id: string;
};

export function oversizePayloadResponse(payload: OversizePayload): void {
  const { allow, id } = payload;

  if (allow) {
    nextChunk(id);
  } else {
    store.set(chunkingAtom, (prev) => {
      const { [id]: _, ...otherQueues } = prev;
      return otherQueues;
    });
  }
}

export function acknowledgePayloadChunk(payload: OversizePayload): void {
  const { id } = payload;

  store.set(chunkingAtom, (prev) => {
    const { [id]: targetQueue, ...otherQueues } = prev;
    const [_, ...rest] = targetQueue || [];

    return rest.length
      ? {
          ...otherQueues,
          [id]: rest,
        }
      : otherQueues;
  });
  nextChunk(id);
}

/// --------- Helpers -------------------------------------------------------///

function nextChunk(id: string): void {
  const queues = store.get(chunkingAtom);
  const chunk = queues[id]?.[0];

  if (chunk) {
    Byond.sendMessage('payloadChunk', {
      id,
      chunk,
    });
  }
}

type CreateQueueParams = {
  id: string;
  chunks: string[];
};

export function createQueue(payload: CreateQueueParams): void {
  const { id, chunks } = payload;

  store.set(chunkingAtom, (prev) => ({
    ...prev,
    [id]: chunks,
  }));
}

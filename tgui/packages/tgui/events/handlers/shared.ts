import { sharedAtom, store } from '../store';

/// --------- Helpers ------------------------------------------------------///

type SharedPayload = {
  key: string;
  nextState: any;
};

export function setSharedState(payload: SharedPayload): void {
  const { key, nextState } = payload;

  store.set(sharedAtom, (prev) => ({
    ...prev,
    [key]: nextState,
  }));
}

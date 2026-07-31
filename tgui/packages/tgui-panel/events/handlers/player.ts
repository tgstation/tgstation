import { chatRenderer } from '../../chat/renderer';
import {
  characterProfilesAtom,
  currentCharacterAtom,
  currentJobAtom,
} from '../../game/atoms';
import { store } from '../store';

type PlayerSetPayload = {
  job?: string | null;
  character?: string | null;
  characters?: (string | null)[] | null;
};

export function playerSet(payload: PlayerSetPayload) {
  const job = payload?.job || null;
  const character = payload?.character || null;
  // Drop empty save slots and duplicates
  const characters = [
    ...new Set((payload?.characters || []).filter(Boolean) as string[]),
  ];
  store.set(currentJobAtom, job);
  store.set(currentCharacterAtom, character);
  store.set(characterProfilesAtom, characters);
  chatRenderer.setJob(job);
  chatRenderer.setCharacter(character);
}

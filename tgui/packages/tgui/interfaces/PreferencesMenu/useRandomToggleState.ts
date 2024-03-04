import { useLocalState } from '../../backend';

export const useRandomToggleState = () => useLocalState('randomToggle', false);

import { useLocalState } from '../../backend';

export const useRandomToggleState = (context) =>
  useLocalState(context, 'randomToggle', false);

import { useLocalState } from "../../backend";

export const useRandomToggleState: (context) => [
  boolean, (newValue: boolean) => void
]
  = context => useLocalState(context, "randomToggle", false);

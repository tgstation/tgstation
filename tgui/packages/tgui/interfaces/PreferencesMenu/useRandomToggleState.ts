import { createContext, Dispatch, SetStateAction, useContext } from 'react';

export const RandomToggleState = createContext<
  [boolean, Dispatch<SetStateAction<boolean>>]
>([false, () => {}]);

export function useRandomToggleState() {
  const context = useContext(RandomToggleState);

  return context;
}

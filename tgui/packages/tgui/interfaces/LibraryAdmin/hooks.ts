import {
  createContext,
  type Dispatch,
  type SetStateAction,
  useContext,
} from 'react';

type Context = {
  modifyMethodState: [string, Dispatch<SetStateAction<string>>];
  modifyTargetState: [number, Dispatch<SetStateAction<number>>];
};

export const ModifyState = createContext<Context>({
  modifyMethodState: ['', () => {}],
  modifyTargetState: [0, () => {}],
});

export function useModifyState() {
  return useContext(ModifyState);
}

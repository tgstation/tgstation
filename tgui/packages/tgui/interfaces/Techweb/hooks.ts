import { createContext, Dispatch, SetStateAction, useContext } from 'react';

type Route = {
  route: string;
  diskType?: string;
  selectedNode?: string;
};

export const TechWebRoute = createContext<
  [Route, Dispatch<SetStateAction<Route>>]
>([
  {
    route: '',
  },
  () => {},
]);

export function useTechWebRoute() {
  return useContext(TechWebRoute);
}

import { useSelector } from "tgui/store";
import { selectGameState } from './selectors';

export const useGameState = context => {
  return useSelector(context, selectGameState);
};

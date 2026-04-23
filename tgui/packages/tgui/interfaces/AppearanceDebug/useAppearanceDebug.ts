import {
  createContext,
  type Dispatch,
  type SetStateAction,
  useContext,
} from 'react';
import type { sendAct } from 'tgui/events/act';
import type { AppearanceMap } from './types';

type AppearanceDebug = {
  act: typeof sendAct;
  planeToText: Record<string, number>;
  layerToText: Record<string, number>;
  mapRefHover: string;
  mapRefSelected: string;
  appsProcessed: AppearanceMap;
  zoomToX: number | undefined;
  setZoomToX: Dispatch<SetStateAction<number | undefined>>;
  zoomToY: number | undefined;
  setZoomToY: Dispatch<SetStateAction<number | undefined>>;
};

export const AppearanceDebugContext = createContext({} as AppearanceDebug);

export function useAppearanceDebugContext() {
  return useContext(AppearanceDebugContext);
}

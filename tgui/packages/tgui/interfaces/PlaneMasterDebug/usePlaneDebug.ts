import {
  createContext,
  type Dispatch,
  type SetStateAction,
  useContext,
} from 'react';

import type { PlaneHighlight, PlaneMap } from './types';

type PlaneDebug = {
  connectionHighlight: PlaneHighlight | undefined;
  setConnectionHighlight: Dispatch<SetStateAction<PlaneHighlight | undefined>>;
  activePlane: number | undefined;
  setActivePlane: Dispatch<SetStateAction<number | undefined>>;
  connectionOpen: boolean;
  setConnectionOpen: Dispatch<SetStateAction<boolean>>;
  infoOpen: boolean;
  setInfoOpen: Dispatch<SetStateAction<boolean>>;
  planeOpen: boolean;
  setPlaneOpen: Dispatch<SetStateAction<boolean>>;
  planesProcessed: PlaneMap;
  zoomToX: number | undefined;
  setZoomToX: Dispatch<SetStateAction<number | undefined>>;
  zoomToY: number | undefined;
  setZoomToY: Dispatch<SetStateAction<number | undefined>>;
};

export const PlaneDebugContext = createContext({} as PlaneDebug);

export function usePlaneDebugContext() {
  return useContext(PlaneDebugContext);
}

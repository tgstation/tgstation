import { createContext, Dispatch, SetStateAction, useState } from 'react';
import { Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { VIEWMODE } from './constants';
import { OrbitBlade } from './OrbitBlade';
import { OrbitContent } from './OrbitContent';
import { OrbitSearchBar } from './OrbitSearchBar';
import { ViewMode } from './types';

export function Orbit(props) {
  const [autoObserve, setAutoObserve] = useState(false);
  const [bladeOpen, setBladeOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [viewMode, setViewMode] = useState<ViewMode>(VIEWMODE.Health);

  const dynamicWidth = bladeOpen ? 650 : 400;

  return (
    <OrbitContext.Provider
      value={{
        autoObserve,
        setAutoObserve,
        bladeOpen,
        setBladeOpen,
        searchQuery,
        setSearchQuery,
        viewMode,
        setViewMode,
      }}
    >
      <Window title="Orbit" width={dynamicWidth} height={550}>
        <Window.Content>
          <Stack fill>
            <Stack.Item grow>
              <Stack fill vertical>
                <Stack.Item>
                  <OrbitSearchBar />
                </Stack.Item>
                <Stack.Item grow>
                  <OrbitContent />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            {bladeOpen && (
              <Stack.Item>
                <OrbitBlade />
              </Stack.Item>
            )}
          </Stack>
        </Window.Content>
      </Window>
    </OrbitContext.Provider>
  );
}

type Context = {
  autoObserve: boolean;
  setAutoObserve: Dispatch<SetStateAction<boolean>>;
  bladeOpen: boolean;
  setBladeOpen: Dispatch<SetStateAction<boolean>>;
  searchQuery: string;
  setSearchQuery: Dispatch<SetStateAction<string>>;
  viewMode: ViewMode;
  setViewMode: Dispatch<SetStateAction<ViewMode>>;
};

export const OrbitContext = createContext({} as Context);

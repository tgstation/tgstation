import { createContext, useState } from 'react';
import { Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { VIEWMODE } from './constants';
import { OrbitContent } from './OrbitContent';
import { OrbitSearchBar } from './OrbitSearchBar';
import { ViewMode } from './types';

export function Orbit(props) {
  const [autoObserve, setAutoObserve] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [viewMode, setViewMode] = useState<ViewMode>(VIEWMODE.Health);

  return (
    <OrbitContext.Provider
      value={{
        autoObserve,
        setAutoObserve,
        searchQuery,
        setSearchQuery,
        viewMode,
        setViewMode,
      }}
    >
      <Window title="Orbit" width={400} height={550}>
        <Window.Content scrollable>
          <Stack fill vertical>
            <Stack.Item>
              <OrbitSearchBar />
            </Stack.Item>
            <Stack.Item mt={0.2} grow>
              <OrbitContent />
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    </OrbitContext.Provider>
  );
}

export const OrbitContext = createContext({
  autoObserve: false,
  setAutoObserve: (bool: boolean) => {},
  searchQuery: '',
  setSearchQuery: (str: string) => {},
  viewMode: VIEWMODE.Health as ViewMode,
  setViewMode: (mode: ViewMode) => {},
});

import { useState } from 'react';
import { Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { VIEWMODE } from './constants';
import { ObservableContent } from './ObservableContent';
import { OrbitSearch } from './OrbitSearch';
import { ViewMode } from './types';

export function Orbit(props) {
  const [autoObserve, setAutoObserve] = useState(false);
  const [viewMode, setViewMode] = useState<ViewMode>(VIEWMODE.Health);
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <Window title="Orbit" width={400} height={550}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <OrbitSearch
              autoObserve={autoObserve}
              searchQuery={searchQuery}
              setAutoObserve={setAutoObserve}
              setSearchQuery={setSearchQuery}
              setViewMode={setViewMode}
              viewMode={viewMode}
            />
          </Stack.Item>
          <Stack.Item mt={0.2} grow>
            <ObservableContent
              autoObserve={autoObserve}
              searchQuery={searchQuery}
              viewMode={viewMode}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

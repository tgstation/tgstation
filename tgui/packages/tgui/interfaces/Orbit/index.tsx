import { useState } from 'react';
import { Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { VIEWMODE } from './constants';
import { ObservableContent } from './ObservableContent';
import { OrbitSearch } from './OrbitSearch';
import { ViewMode } from './types';

export function Orbit(props) {
  const autoObserveState = useState(false);
  const searchQueryState = useState('');
  const viewModeState = useState<ViewMode>(VIEWMODE.Health);

  return (
    <Window title="Orbit" width={400} height={550}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <OrbitSearch
              autoObserve={autoObserveState}
              searchQuery={searchQueryState}
              viewMode={viewModeState}
            />
          </Stack.Item>
          <Stack.Item mt={0.2} grow>
            <ObservableContent
              autoObserve={autoObserveState[0]}
              searchQuery={searchQueryState[0]}
              viewMode={viewModeState[0]}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

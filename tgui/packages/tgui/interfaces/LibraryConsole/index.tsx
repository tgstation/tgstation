import { useState } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PopoutMenu } from './components/PopoutMenu';
import { Archive } from './screens/Archive';
import { Checkout } from './screens/Checkout';
import { Forbidden } from './screens/Forbidden';
import { Inventory } from './screens/Inventory';
import { Print } from './screens/Print';
import { Upload } from './screens/Upload';
import type { LibraryConsoleData } from './types';
import { LibraryContext } from './useLibraryContext';

export function LibraryConsole(props) {
  const { data } = useBackend<LibraryConsoleData>();
  const { display_lore, screen_state } = data;

  const checkoutBookState = useState(false);
  const uploadToDBState = useState(false);

  return (
    <LibraryContext.Provider value={{ checkoutBookState, uploadToDBState }}>
      <Window
        theme={display_lore ? 'spookyconsole' : ''}
        title="Library Terminal"
        width={880}
        height={520}
      >
        <Window.Content>
          <Stack fill>
            <Stack.Item>
              <PopoutMenu />
            </Stack.Item>
            <Stack.Item grow>
              {screen_state === 1 && <Inventory />}
              {screen_state === 2 && <Checkout />}
              {screen_state === 3 && <Archive />}
              {screen_state === 4 && <Upload />}
              {screen_state === 5 && <Print />}
              {screen_state === 6 && <Forbidden />}
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    </LibraryContext.Provider>
  );
}

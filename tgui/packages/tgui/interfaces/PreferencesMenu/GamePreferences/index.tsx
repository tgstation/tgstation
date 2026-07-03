import { useState } from 'react';
import { Stack, Tabs } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { PageButton } from '../components/PageButton';
import { GamePreferencesSelectedPage } from '../types';
import { GamePreferencesPage } from './GamePreferencesPage';
import { KeybindingsPage } from './KeybindingsPage';

type Props = {
  startingPage?: GamePreferencesSelectedPage;
};

export function GamePreferenceWindow(props: Props) {
  const [currentPage, setCurrentPage] = useState(
    props.startingPage ?? GamePreferencesSelectedPage.Settings,
  );

  let pageContents;
  switch (currentPage) {
    case GamePreferencesSelectedPage.Keybindings:
      pageContents = <KeybindingsPage />;
      break;
    case GamePreferencesSelectedPage.Settings:
      pageContents = <GamePreferencesPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid textAlign="center">
          <PageButton
            icon="cogs"
            currentPage={currentPage}
            page={GamePreferencesSelectedPage.Settings}
            setPage={setCurrentPage}
          >
            Настройки
          </PageButton>
          <PageButton
            icon="keyboard"
            currentPage={currentPage}
            page={GamePreferencesSelectedPage.Keybindings}
            setPage={setCurrentPage}
          >
            Управление
          </PageButton>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>{pageContents}</Stack.Item>
    </Stack>
  );
}

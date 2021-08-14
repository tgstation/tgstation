import { Box, Button, ByondUi, Flex, Icon, Popper, Stack } from "../../components";
import { Window } from "../../layouts";
import { KeybindingsPage } from "./KeybindingsPage";
import { GamePreferencesPage } from "./GamePreferencesPage";
import { PageButton } from "./PageButton";
import { useBackend, useLocalState } from "../../backend";
import { PreferencesMenuData } from "./data";
import { exhaustiveCheck } from "common/exhaustive";

enum Page {
  Settings,
  Keybindings,
}

export const GamePreferenceWindow = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  const [currentPage, setCurrentPage] = useLocalState(context, "currentPage", Page.Settings);

  let pageContents;

  switch (currentPage) {
    case Page.Keybindings:
      pageContents = <KeybindingsPage />;
      break;
    case Page.Settings:
      pageContents = <GamePreferencesPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }


  return (
    <Window
      title="Game Preferences"
      width={920}
      height={770}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Settings}
                  setPage={setCurrentPage}
                >
                  Settings
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Keybindings}
                  setPage={setCurrentPage}
                >
                  Keybindings
                </PageButton>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item grow shrink basis="1px">
            {pageContents}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

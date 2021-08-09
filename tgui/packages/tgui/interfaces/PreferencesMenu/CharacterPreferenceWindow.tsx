import { exhaustiveCheck } from "common/exhaustive";
import { classes } from "common/react";
import { sendAct, useBackend, useLocalState } from "../../backend";
import { Box, Button, ByondUi, Flex, Icon, Popper, Stack } from "../../components";
import { Window } from "../../layouts";
import { CharacterProfile, PreferencesMenuData } from "./data";
import { AntagsPage } from "./AntagsPage";
import { GamePreferencesPage } from "./GamePreferencesPage";
import { JobsPage } from "./JobsPage";
import { MainPage } from "./MainPage";
import { SpeciesPage } from "./SpeciesPage";
import { QuirksPage } from "./QuirksPage";
import { StatelessComponent } from "inferno";

enum Page {
  Antags,
  Main,
  Jobs,
  Species,
  Quirks,
}

const CharacterProfiles = (props: {
  activeName: string,
  onClick: (index: number) => void,
  profiles: (CharacterProfile | null)[],
}) => {
  const { profiles } = props;

  return (
    <Stack justify="center" wrap>
      {profiles.map((profile, slot) => (
        <Stack.Item key={slot}>
          <Button
            selected={profile?.name === props.activeName}
            onClick={() => {
              props.onClick(slot);
            }} fluid>{profile ? profile.name : "New Character"}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const PageButton: StatelessComponent<{
  currentPage: Page,
  page: Page,

  setPage: (page: Page) => void,
}> = (props) => {
  return (
    <Button
      align="center"
      fontSize="1.2em"
      fluid
      selected={props.currentPage === props.page}
      onClick={() => props.setPage(props.page)}
    >
      {props.children}
    </Button>
  );
};

export const CharacterPreferenceWindow = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  const [currentPage, setCurrentPage] = useLocalState(context, "currentPage", Page.Main);

  let pageContents;

  switch (currentPage) {
    case Page.Antags:
      pageContents = <AntagsPage />;
      break;
    case Page.Jobs:
      pageContents = <JobsPage />;
      break;
    case Page.Main:
      pageContents = (<MainPage
        openSpecies={() => setCurrentPage(Page.Species)}
      />);

      break;
    case Page.Species:
      pageContents = <SpeciesPage />;
      break;
    case Page.Quirks:
      pageContents = <QuirksPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window
      title="Character Preferences"
      width={920}
      height={770}
      scrollable
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <CharacterProfiles
              activeName={data.active_name}
              onClick={(slot) => {
                act("change_slot", {
                  slot: slot + 1,
                });
              }} profiles={data.character_profiles} />
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Main}
                  setPage={setCurrentPage}
                >
                  Character
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Jobs}
                  setPage={setCurrentPage}
                >
                  {/*
                    Fun fact: This isn't "Jobs" so that it intentionally
                    catches your eyes, because it's really important!
                  */}

                  Occupations
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Antags}
                  setPage={setCurrentPage}
                >
                  Antagonists
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Quirks}
                  setPage={setCurrentPage}
                >
                  Quirks
                </PageButton>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item>
            {pageContents}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

import { exhaustiveCheck } from 'common/exhaustive';
import { useState } from 'react';

import { useBackend } from '../../backend';
import {
  Dropdown,
  Flex,
  Stack,
} from '../../components'; /* DOPPLER EDIT: Adds in Dropdown and Flex */
import { Window } from '../../layouts';
import { AntagsPage } from './AntagsPage';
import { PreferencesMenuData } from './data';
import { JobsPage } from './JobsPage';
import { LanguagesPage } from './LanguagesMenu'; /* DOPPLER ADDITION */
import { LoadoutPage } from './loadout/index';
import { LorePage } from './LorePage'; /* DOPPLER ADDITION */
import { MainPage } from './MainPage';
import { PageButton } from './PageButton';
import { QuirksPage } from './QuirksPage';
import { SpeciesPage } from './SpeciesPage';

enum Page {
  Antags,
  Main,
  Jobs,
  // DOPPLER EDIT
  Lore,
  Languages,
  // DOPPLER EDIT END
  Species,
  Quirks,
  Loadout,
}

const CharacterProfiles = (props: {
  activeSlot: number;
  onClick: (index: number) => void;
  profiles: (string | null)[];
}) => {
  const { profiles, activeSlot, onClick } =
    props; /* DOPPLER EDIT: activeSlot and onClick */

  return (
    <Flex /* DOPPLER EDIT START: Dropdown instead of using buttons */
      align="center"
      justify="center"
    >
      <Flex.Item width="25%">
        <Dropdown
          width="100%"
          selected={activeSlot as unknown as string}
          displayText={profiles[activeSlot]}
          options={profiles.map((profile, slot) => ({
            value: slot,
            displayText: profile ?? 'New Character',
          }))}
          onSelected={(slot) => {
            onClick(slot);
          }}
        />
      </Flex.Item>
    </Flex> /* DOPPLER EDIT END */
  );
};

export const CharacterPreferenceWindow = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();

  const [currentPage, setCurrentPage] = useState(Page.Main);

  let pageContents;

  switch (currentPage) {
    case Page.Antags:
      pageContents = <AntagsPage />;
      break;
    case Page.Jobs:
      pageContents = <JobsPage />;
      break;
    // DOPPLER EDIT
    case Page.Languages:
      pageContents = <LanguagesPage />;
      break;
    // DOPPLER EDIT END
    case Page.Main:
      pageContents = (
        <MainPage openSpecies={() => setCurrentPage(Page.Species)} />
      );

      break;
    case Page.Species:
      pageContents = (
        <SpeciesPage closeSpecies={() => setCurrentPage(Page.Main)} />
      );

      break;
    case Page.Quirks:
      pageContents = <QuirksPage />;
      break;

    case Page.Loadout:
      pageContents = <LoadoutPage />;
      break;
    /* DOPPLER ADDITION START */
    case Page.Lore:
      pageContents = <LorePage />;
      break;
    /* DOPPLER ADDITION END */

    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window title="Character Preferences" width={920} height={770}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <CharacterProfiles
              activeSlot={data.active_slot - 1}
              onClick={(slot) => {
                act('change_slot', {
                  slot: slot + 1,
                });
              }}
              profiles={data.character_profiles}
            />
          </Stack.Item>
          {/* // DOPPLER EDIT: Hide Byond premium banner

          {!data.content_unlocked && (
            <Stack.Item align="center">
              Buy BYOND premium for more slots!
            </Stack.Item>
          )}

           */}
          <Stack.Divider />
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Main}
                  setPage={setCurrentPage}
                  otherActivePages={[Page.Species]}
                >
                  Character
                </PageButton>
              </Stack.Item>
              {
                // DOPPLER EDIT: fancy flavour text & character report stuff
              }
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Lore}
                  setPage={setCurrentPage}
                >
                  Lore
                </PageButton>
              </Stack.Item>

              {
                // DOPPLER EDIT END
              }
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Loadout}
                  setPage={setCurrentPage}
                >
                  Loadout
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
              {
                // DOPPLER EDIT
              }
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Languages}
                  setPage={setCurrentPage}
                >
                  Languages
                </PageButton>
              </Stack.Item>
              {
                // DOPPLER EDIT END
              }
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
          <Stack.Item>{pageContents}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Dropdown,
  Flex,
  Stack,
} from 'tgui-core/components'; /* DOPPLER EDIT: Adds in Dropdown and Flex */
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { PageButton } from '../components/PageButton';
import { LanguagesPage } from '../LanguagesMenu'; /* DOPPLER EDIT ADDITION */
import { LorePage } from '../LorePage'; /* DOPPLER EDIT ADDITION */
import { MortalPage } from '../Mortal';
import { PowersPage } from '../PowersMenu'; /* DOPPLER EDIT ADDITION */
import { ResonantPage } from '../Resonant';
import { SorcerousPage } from '../Sorcerous';
import { PreferencesMenuData } from '../types';
import { AntagsPage } from './AntagsPage';
import { JobsPage } from './JobsPage';
import { LoadoutPage } from './loadout';
import { MainPage } from './MainPage';
import { QuirksPage } from './QuirksPage';
import { SpeciesPage } from './SpeciesPage';

enum Page {
  Antags,
  Main,
  Jobs,
  Species,
  Quirks,
  Loadout,
  Languages /* DOPPLER EDIT ADDITION */,
  Lore /* DOPPLER EDIT ADDITION */,
  Powers /* DOPPLER EDITION ADDITION */,
  Mortal /* DOPPLER EDIT ADDITION */,
  Sorcerous /* DOPPLER EDIT ADDITION */,
  Resonant /* DOPPLER EDIT ADDITION */,
}

type ProfileProps = {
  activeSlot: number;
  onClick: (index: number) => void;
  profiles: (string | null)[];
};

function CharacterProfiles(props: ProfileProps) {
  const { activeSlot, onClick, profiles } = props;

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
}

export function CharacterPreferenceWindow(props) {
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

    // DOPPLER EDIT START

    case Page.Lore:
      pageContents = <LorePage />;
      break;

    case Page.Languages:
      pageContents = <LanguagesPage />;
      break;

    case Page.Mortal:
      pageContents = (
        <MortalPage handleCloseMortal={() => setCurrentPage(Page.Powers)} />
      );
      break;

    case Page.Resonant:
      pageContents = (
        <ResonantPage handleCloseResonant={() => setCurrentPage(Page.Powers)} />
      );
      break;

    case Page.Sorcerous:
      pageContents = (
        <SorcerousPage
          handleCloseSorcerous={() => setCurrentPage(Page.Powers)}
        />
      );
      break;

    case Page.Powers:
      pageContents = (
        <PowersPage
          handleOpenMortal={() => setCurrentPage(Page.Mortal)}
          handleOpenSorcerous={() => setCurrentPage(Page.Sorcerous)}
          handleOpenResonant={() => setCurrentPage(Page.Resonant)}
        />
      );
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

    default:
      exhaustiveCheck(currentPage);
  }

  return (
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

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Lore}
              setPage={setCurrentPage}
            >
              Lore
            </PageButton>
          </Stack.Item>

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

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Languages}
              setPage={setCurrentPage}
            >
              Languages
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Powers}
              setPage={setCurrentPage}
              otherActivePages={[Page.Mortal, Page.Sorcerous, Page.Resonant]}
            >
              Powers
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
      <Stack.Item>{pageContents}</Stack.Item>
    </Stack>
  );
}

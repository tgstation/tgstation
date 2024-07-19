import { exhaustiveCheck } from 'common/exhaustive';
import { useState } from 'react';

import { useBackend } from '../../../backend';
import { Flex, SideDropdown, Stack } from '../../../components';
import { Window } from '../../../layouts';
import { AntagsPage } from '../AntagsPage';
import { PreferencesMenuData } from '../data';
import { JobsPage } from '../JobsPage';
import { PageButton } from '../PageButton';
import { QuirksPage } from '../QuirksPage';
import { SpeciesPage } from '../SpeciesPage';
import { MainPage } from './MainPage';
enum Page {
  Antags,
  Main,
  Jobs,
  Limbs,
  Languages,
  Species,
  Quirks,
}

const CharacterProfiles = (props: {
  activeSlot: number;
  onClick: (index: number) => void;
  profiles: (string | null)[];
}) => {
  const { profiles, activeSlot, onClick } = props;
  return (
    <Flex align="center" justify="left">
      <Flex.Item width="336px">
        <SideDropdown
          width="100%"
          selected={activeSlot}
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
    </Flex>
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
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window title="Character Preferences" width={1143} height={754}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              <Stack.Item width="224.5px" fontSize="14px">
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
              <Stack.Item grow={1} ml="10px">
                <PageButton
                  currentPage={currentPage}
                  page={Page.Main}
                  setPage={setCurrentPage}
                  otherActivePages={[Page.Species]}
                >
                  Character
                </PageButton>
              </Stack.Item>

              <Stack.Item grow={1}>
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
              <Stack.Item grow={1}>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Limbs}
                  setPage={setCurrentPage}
                >
                  Augments+
                </PageButton>
              </Stack.Item>

              <Stack.Item grow={1}>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Languages}
                  setPage={setCurrentPage}
                >
                  Languages
                </PageButton>
              </Stack.Item>

              <Stack.Item grow={1}>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Antags}
                  setPage={setCurrentPage}
                >
                  Antagonists
                </PageButton>
              </Stack.Item>

              <Stack.Item grow={1}>
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

          <Stack.Item mt={1}>{pageContents}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

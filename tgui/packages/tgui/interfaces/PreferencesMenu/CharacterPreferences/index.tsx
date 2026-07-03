import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Floating, Section, Stack, Tabs } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { PageButton } from '../components/PageButton';
import type { PreferencesMenuData } from '../types';
import { AntagsPage } from './AntagsPage';
import { JobsPage } from './JobsPage';
import { LoadoutPage } from './loadout';
import { MainPage } from './MainPage';
import { QuirkPersonalityPage } from './QuirksPage';
import { SpeciesPage } from './SpeciesPage';
import { VoicePage } from './VoicePage';

enum Page {
  Antags,
  Main,
  Jobs,
  Species,
  Quirks,
  Loadout,
  Voice,
}

type ProfileProps = {
  activeSlot: number;
  profiles: (string | null)[];
  onClick: (index: number) => void;
};

function CharacterProfiles(props: ProfileProps) {
  const { activeSlot, onClick, profiles } = props;
  return (
    <div className="PreferencesMenu__ChoicedSelection Characters">
      <Section fill scrollable title="Персонажи">
        <Stack fill vertical>
          {profiles.map((profile, slot) => (
            <Stack.Item key={slot}>
              <Button
                fluid
                ellipsis
                selected={slot === activeSlot}
                onClick={() => {
                  onClick(slot);
                }}
              >
                {profile ?? 'Новый персонаж'}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </div>
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
      pageContents = <QuirkPersonalityPage />;
      break;

    case Page.Loadout:
      pageContents = <LoadoutPage />;
      break;

    case Page.Voice:
      pageContents = <VoicePage />;
      break;

    default:
      exhaustiveCheck(currentPage);
  }

  function CharacterSelection(props) {
    return (
      <Floating
        placement="bottom-end"
        content={
          <CharacterProfiles
            activeSlot={data.active_slot - 1}
            profiles={data.character_profiles}
            onClick={(slot) => {
              act('change_slot', {
                slot: slot + 1,
              });
            }}
          />
        }
      >
        <Button icon="user">Выбрать персонажа</Button>
      </Floating>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          fitted
          title={
            data.character_profiles[data.active_slot - 1] || 'Новый персонаж'
          }
          buttons={<CharacterSelection />}
        >
          <Tabs fluid textAlign="center">
            <PageButton
              icon="user"
              currentPage={currentPage}
              page={Page.Main}
              setPage={setCurrentPage}
              otherActivePages={[Page.Species]}
            >
              Персонаж
            </PageButton>
            <PageButton
              icon="suitcase"
              currentPage={currentPage}
              page={Page.Loadout}
              setPage={setCurrentPage}
            >
              Снаряжение
            </PageButton>
            <PageButton
              icon="user-astronaut"
              currentPage={currentPage}
              page={Page.Jobs}
              setPage={setCurrentPage}
            >
              Должности
            </PageButton>
            <PageButton
              icon="skull"
              currentPage={currentPage}
              page={Page.Antags}
              setPage={setCurrentPage}
            >
              Антагонисты
            </PageButton>
            <PageButton
              icon="wheelchair-move"
              currentPage={currentPage}
              page={Page.Quirks}
              setPage={setCurrentPage}
            >
              Черты и характер
            </PageButton>
            {!!data.tts_enabled && (
              <PageButton
                icon="microphone-lines"
                currentPage={currentPage}
                page={Page.Voice}
                setPage={setCurrentPage}
              >
                Голос
              </PageButton>
            )}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow position="relative" overflowX="hidden" overflowY="auto">
        {pageContents}
      </Stack.Item>
    </Stack>
  );
}

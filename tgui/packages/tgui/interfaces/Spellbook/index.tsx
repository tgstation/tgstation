import { sample } from 'es-toolkit';
import { atom, useAtom } from 'jotai';
import { useEffect, useState } from 'react';
import {
  Button,
  Input,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { SearchSpells } from './SearchSpells';
import { SpellResults } from './SpellResults';
import { type SpellbookData, Tab } from './types';

export const tabAtom = atom(Tab.TableOfContents);
export const spellSearchAtom = atom('');

export const widthSection = '466px';
export const heightSection = '456px';

const searchVerbs = [
  'Поиск',
  'В поиске',
  'Размышление',
  'Предсказание',
  'Ясновидение',
  'Подглядывание',
  'Раздумье',
  'Вглядывание',
  'Изучение',
  'Просмотр',
];

export function Spellbook(props) {
  const { data } = useBackend<SpellbookData>();
  const { points } = data;

  const [selectedVerb, setSelectedVerb] = useState(searchVerbs[0]);
  const [spellSearch, setSpellSearch] = useAtom(spellSearchAtom);

  useEffect(() => {
    // Ensures it only changes on reset
    if (spellSearch === '') {
      setSelectedVerb(sample(searchVerbs));
    }
  }, [spellSearch]);

  return (
    <Window title="Книга заклинаний" theme="wizard" width={950} height={540}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              {spellSearch.length > 1 ? (
                <Stack.Item grow>
                  <Section
                    title={`${selectedVerb}...`}
                    scrollable
                    height={heightSection}
                    fill
                    buttons={
                      <Button
                        icon="arrow-rotate-left"
                        onClick={() => setSpellSearch('')}
                      >
                        Остановить {selectedVerb}
                      </Button>
                    }
                  >
                    <SearchSpells />
                  </Section>
                </Stack.Item>
              ) : (
                <SpellResults />
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item grow>
                  <ProgressBar value={points / 10}>
                    {`Осталось очков: ${points}`}
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    width={15}
                    placeholder="Поиск заклинания..."
                    onChange={setSpellSearch}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

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
  'Searching',
  'Seeking',
  'Contemplating',
  'Divining',
  'Scrying',
  'Peeking',
  'Pondering',
  'Gazing',
  'Studying',
  'Reviewing',
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
    <Window title="Spellbook" theme="wizard" width={950} height={540}>
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
                        Stop {selectedVerb}
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
                    {`${points} points left to spend.`}
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    width={15}
                    placeholder="Search for a spell..."
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

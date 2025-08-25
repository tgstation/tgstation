import { atom, useAtom } from 'jotai';
import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Input,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CategoryDisplay } from './CategoryDisplay';
import { TAB2NAME } from './constants';
import { SearchSpells } from './SearchSpells';
import { type SpellbookData, Tab } from './types';

export const tabAtom = atom(Tab.TableOfContents);
export const spellSearchAtom = atom('');

const widthSection = '466px';
const heightSection = '456px';

// Has a chance of selecting a random funny verb instead of "Searching"
function selectSearchVerb(): string {
  const found = Math.random();
  if (found <= 0.03) {
    return 'Seeking';
  }
  if (found <= 0.06) {
    return 'Contemplating';
  }
  if (found <= 0.09) {
    return 'Divining';
  }
  if (found <= 0.12) {
    return 'Scrying';
  }
  if (found <= 0.15) {
    return 'Peeking';
  }
  if (found <= 0.18) {
    return 'Pondering';
  }
  if (found <= 0.21) {
    return 'Divining';
  }
  if (found <= 0.24) {
    return 'Gazing';
  }
  if (found <= 0.27) {
    return 'Studying';
  }
  if (found <= 0.3) {
    return 'Reviewing';
  }

  return 'Searching';
}

export function Spellbook(props) {
  const { data } = useBackend<SpellbookData>();
  const { points } = data;

  const [selectedVerb, setSelectedVerb] = useState('');
  const [spellSearch, setSpellSearch] = useAtom(spellSearchAtom);

  useEffect(() => {
    setSelectedVerb(selectSearchVerb());
  }, []);

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
                <SearchedSpell />
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

function SearchedSpell() {
  const [tabIndex, setTabIndex] = useAtom(tabAtom);

  const activeCat = TAB2NAME[tabIndex - 1];
  const activeNextCat = TAB2NAME[tabIndex];

  return (
    <>
      <Stack.Item grow>
        <Section
          scrollable={activeCat.scrollable}
          textAlign="center"
          width={widthSection}
          height={heightSection}
          fill
          title={activeCat.title}
          buttons={
            <>
              <Button
                mr={57}
                disabled={tabIndex === 1}
                icon="arrow-left"
                onClick={() => setTabIndex(tabIndex - 2)}
              >
                Previous Page
              </Button>
              <Box textAlign="right" bold mt={-3.3} mr={1}>
                {tabIndex}
              </Box>
            </>
          }
        >
          <CategoryDisplay activeCat={activeCat} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          scrollable={activeNextCat.scrollable}
          textAlign="center"
          width={widthSection}
          height={heightSection}
          fill
          title={activeNextCat.title}
          buttons={
            <>
              <Button
                mr={0}
                icon="arrow-right"
                disabled={tabIndex === 11}
                onClick={() => setTabIndex(tabIndex + 2)}
              >
                Next Page
              </Button>
              <Box textAlign="left" bold mt={-3.3} ml={-59.8}>
                {tabIndex + 1}
              </Box>
            </>
          }
        >
          <CategoryDisplay activeCat={activeNextCat} />
        </Section>
      </Stack.Item>
    </>
  );
}

import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Stack, Tabs } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import type { LibraryConsoleData } from '../types';

export function Print(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { bible_name, bible_sprite, deity, posters, religion } = data;

  const [selectedPoster, setSelectedPoster] = useState(posters[0]);

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item width="50%">
            <Section fill scrollable>
              <Tabs vertical>
                {posters.map((poster) => {
                  const selected = selectedPoster === poster;

                  return (
                    <Tabs.Tab
                      className="candystripe"
                      selected={selected}
                      color={selected && 'good'}
                      key={poster}
                      onClick={() => setSelectedPoster(poster)}
                    >
                      {poster}
                    </Tabs.Tab>
                  );
                })}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical height="100%">
              <Stack.Item
                textAlign="center"
                fontSize="25px"
                italic
                bold
                textColor="#0b94c4"
              >
                {bible_name}
              </Stack.Item>
              <Stack.Item textAlign="center" fontSize="22px" textColor="purple">
                In the Name of {deity}
              </Stack.Item>
              <Stack.Item textAlign="center" fontSize="22px" textColor="purple">
                For the Sake of {religion}
              </Stack.Item>
              <Stack.Item align="center">
                <Box className={classes(['bibles224x224', bible_sprite])} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack justify="space-between">
          <Stack.Item grow>
            <Button
              fluid
              icon="scroll"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              onClick={() =>
                act('print_poster', {
                  poster_name: selectedPoster,
                })
              }
            >
              Poster
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="cross"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              onClick={() => act('print_bible')}
            >
              Bible
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

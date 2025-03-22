import { useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { LibraryConsoleData } from './types';

export function Print(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { deity, religion, bible_name, bible_sprite, posters } = data;
  const [selectedPoster, setSelectedPoster] = useState(posters[0]);

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item width="50%">
            <Section fill scrollable>
              {posters.map((poster) => (
                <div
                  key={poster}
                  title={poster}
                  className={classes([
                    'Button',
                    'Button--fluid',
                    'Button--color--transparent',
                    'Button--ellipsis',
                    selectedPoster &&
                      poster === selectedPoster &&
                      'Button--selected',
                  ])}
                  onClick={() => setSelectedPoster(poster)}
                >
                  {poster}
                </div>
              ))}
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
              content="Poster"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              onClick={() =>
                act('print_poster', {
                  poster_name: selectedPoster,
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="cross"
              content="Bible"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              onClick={() => act('print_bible')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

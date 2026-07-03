import { Box, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { CharacterPreview } from './common/CharacterPreview';

type Data = {
  character_name: string;
  obscured: BooleanLike;
  assigned_map: string;
  flavor_text: string;
};

export const ExaminePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { character_name, obscured, assigned_map, flavor_text } = data;
  return (
    <Window title="Подробное описание" width={600} height={350} theme="ntos">
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <Section fill title="Превью персонажа">
              {!obscured && (
                <CharacterPreview id={assigned_map} height="100%" />
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section
                  scrollable
                  fill
                  title={`${character_name}, описание:`}
                >
                  <Box
                    style={{
                      whiteSpace: 'pre-wrap',
                      wordBreak: 'break-word',
                      overflowWrap: 'break-word',
                    }}
                  >
                    {flavor_text}
                  </Box>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

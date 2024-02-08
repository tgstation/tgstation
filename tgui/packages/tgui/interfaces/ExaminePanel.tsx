import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Section, Stack } from '../components';
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
    <Window title="Examine Panel" width={900} height={670} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item width="30%">
            <Section fill title="Character Preview">
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
                  title={character_name + "'s Flavor Text:"}
                  preserveWhitespace
                >
                  {flavor_text}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

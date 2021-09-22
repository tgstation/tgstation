import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';
 
export const MinigamesMenu = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Window
      title="Minigames Menu"
      width={390}
      height={200}>
      <Window.Content>
        <Section title="Select Minigame" textAlign="center">
          <Stack>
            <Stack.Item>
              <Button
                 content="CTF"
                 height={9}
                 width={15}
                 fontSize={3}
                 textAlign="center"
                 lineHeight="3"
                 onClick={() => act('ctf')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content="Mafia"
                height={9}
                width={15}
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('mafia')}
              />
             </Stack.Item>
          </Stack>  
        </Section>
      </Window.Content>
    </Window>
  );
};

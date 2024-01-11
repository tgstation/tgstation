import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const MinigamesMenu = (props) => {
  const { act } = useBackend();

  return (
    <Window title="Minigames Menu" width={700} height={200}>
      <Window.Content>
        <Section title="Select Minigame" textAlign="center">
          <Stack>
            <Stack.Item grow>
              <Button
                content="CTF"
                fluid
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('ctf')}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                content="Mafia"
                fluid
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('mafia')}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                content="Basketball"
                fluid
                fontSize={3}
                textAlign="center"
                lineHeight="3"
                onClick={() => act('basketball')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const MinigamesMenu = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Minigames Menu"
      width={400}
      height={200}>
      <Window.Content>
        <Section
        title="Select Game"
        textAlign="center"
           />
           {( 
            <>
              <Button
                fluid
                textAlign="center"
                content="CTF"
                onClick={() => act('jump', {
                  name: "spawner.name",
                })} />
              <Button
                fluid
                textAlign="center"
                content="Mafia"
                onClick={() => act('spawn', {
                  name: "spawner.name",
                })} />
            </>
          )}
      </Window.Content>
    </Window>
  );
};

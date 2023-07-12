import { useBackend } from '../backend';
import { Box, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  help_text: string;
};

const DEFAULT_HELP = `No information available! Ask for assistance if needed.`;

export const AvatarHelp = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { help_text = DEFAULT_HELP } = data;

  return (
    <Window title="Avatar Info" width={350} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable title="Welcome to the Virtual Domain.">
              <Box>
                - Study the area and do what needs to be done to recover the
                crate.
              </Box>
              <Box>
                - Bring the crate to the designated sending location in the
                safehouse.
              </Box>
              <Box color="bad">
                - Remember that you are physically linked to this presence.
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              color="good"
              fill
              scrollable
              title="Provided Domain Information">
              {help_text}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

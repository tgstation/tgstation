import { useBackend } from '../backend';
import { Box, Button, Section, Flex, Stack } from '../components';
import { Window } from '../layouts';

export const CTFPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const teams = data.teams || [];
  const enabled = data.enabled || [];
  return (
    <Window
      title="CTF Panel"
      width={700}
      height={600}>
      <Window.Content scrollable>
        <Section title={enabled} textAlign="center">
          <Flex wrap="wrap" justify="space-around">
            {teams.map(team => (
              <Flex.Item key={team.name} minWidth="30%" mb={8}>
                <Section
                  key={team.name}
                  title={`${team.color} Team`}
                >
                  <Stack fill mb={1}>
                    <Stack.Item grow>
                      <Box>
                        <b>{team.team_size}</b> member
                        {team.team_size === 1 ? "" : "s"}
                      </Box>
                    </Stack.Item>

                    <Stack.Item grow>
                      <Box>
                        <b>{team.score}</b> point
                        {team.score === 1 ? "" : "s"}
                      </Box>
                    </Stack.Item>
                  </Stack>

                  <Button
                    content="Jump"
                    fontSize="18px"
                    fluid={1}
                    color={team.color.toLowerCase()}
                    onClick={() => act('jump', {
                      refs: team.refs,
                    })} />

                  <Button
                    content="Join"
                    fontSize="18px"
                    fluid={1}
                    color={team.color.toLowerCase()}
                    onClick={() => act('join', {
                      refs: team.refs,
                    })} />
                </Section>
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

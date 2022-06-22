import { useBackend } from '../backend';
import { Box, Button, Section, Flex, Stack, Divider } from '../components';
import { Window } from '../layouts';

export const CTFPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const teams = data.teams || [];
  const enabled = data.enabled || [];
  return (
    <Window title="CTF Panel" width={700} height={600}>
      <Window.Content scrollable>
        <Box textAlign="center" fontSize="18px">
          {enabled}
        </Box>

        <Divider />

        <Flex align="center" wrap="wrap" textAlign="center" m={-0.5}>
          {teams.map((team) => (
            <Flex.Item key={team.name} width="49%" m={0.5} mb={8}>
              <Section key={team.name} title={`${team.color} Team`}>
                <Stack fill mb={1}>
                  <Stack.Item grow>
                    <Box>
                      <b>{team.team_size}</b> member
                      {team.team_size === 1 ? '' : 's'}
                    </Box>
                  </Stack.Item>

                  <Stack.Item grow>
                    <Box>
                      <b>{team.score}</b> point
                      {team.score === 1 ? '' : 's'}
                    </Box>
                  </Stack.Item>
                </Stack>

                <Button
                  content="Jump"
                  fontSize="18px"
                  fluid={1}
                  color={team.color.toLowerCase()}
                  onClick={() =>
                    act('jump', {
                      refs: team.refs,
                    })
                  }
                />

                <Button
                  content="Join"
                  fontSize="18px"
                  fluid={1}
                  color={team.color.toLowerCase()}
                  onClick={() =>
                    act('join', {
                      refs: team.refs,
                    })
                  }
                />
              </Section>
            </Flex.Item>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};

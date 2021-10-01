import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
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
          {teams.map(team => (
            <Section
              key={team.name}
              title={team.color + ' Team' + ' (Score:' + team.score + ') (Members:' + team.team_size + ')'}>
              <Stack>
                <Stack.Item grow>
                  <Button
                    content="Jump"
                    fluid={1}
                    color={team.color.toLowerCase()}
                    onClick={() => act('jump', {
                      refs: team.refs,
                    })} />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    content="Join"
                    fluid={1}
                    color={team.color.toLowerCase()}
                    onClick={() => act('join', {
                      refs: team.refs,
                    })} /> 
                </Stack.Item>
              </Stack>
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

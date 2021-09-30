import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const CTFPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const teams = data.teams || [];
  return (
    <Window
      title="CTF Panel"
      width={700}
      height={600}>
      <Window.Content scrollable>
        <Section>
          {teams.map(team => (
            <Section
              key={team.name}
              title={team.name + ' (' + team.score + ' points)'}
              level={2}
              buttons={(
                <Button
                  content="Jump"
                  onClick={() => act('jump', {
                    refs: team.refs,
                  })} />
              )} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

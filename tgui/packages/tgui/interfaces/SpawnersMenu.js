import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const SpawnersMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const spawners = data.spawners || [];
  return (
    <Window
      title="Spawners Menu"
      width={700}
      height={600}>
      <Window.Content scrollable>
        <Section>
          {spawners.map(spawner => (
            <Section
              key={spawner.name}
              title={spawner.name + ' (' + spawner.amount_left + ' left)'}
              level={2}
              buttons={(
                <>
                  <Button
                    content="Jump"
                    onClick={() => act('jump', {
                      name: spawner.name,
                    })} />
                  <Button
                    content="Spawn"
                    onClick={() => act('spawn', {
                      name: spawner.name,
                    })} />
                </>
              )}>
              <Box
                bold
                mb={1}
                fontSize="20px">
                {spawner.short_desc}
              </Box>
              <Box>
                {spawner.flavor_text}
              </Box>
              {!!spawner.important_info && (
                <Box
                  mt={1}
                  bold
                  color="bad"
                  fontSize="26px">
                  {spawner.important_info}
                </Box>
              )}
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

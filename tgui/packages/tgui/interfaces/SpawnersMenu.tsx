import { useBackend } from '../backend';
import { Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type SpawnersMenuContext = {
  spawners: spawner[];
};

type spawner = {
  name: string;
  amount_left: number;
  you_are_text?: string;
  flavor_text?: string;
  important_text?: string;
};

export const SpawnersMenu = (props, context) => {
  const { act, data } = useBackend<SpawnersMenuContext>(context);
  const spawners = data.spawners || [];
  return (
    <Window title="Spawners Menu" width={700} height={525}>
      <Window.Content scrollable>
        <Stack vertical>
          {spawners.map((spawner) => (
            <Stack.Item key={spawner.name}>
              <Section
                fill
                // Capitalizes the spawner name
                title={spawner.name.replace(/^\w/, (c) => c.toUpperCase())}
                buttons={
                  <Stack>
                    <Stack.Item fontSize="14px" color="green">
                      {spawner.amount_left} left
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="Jump"
                        onClick={() =>
                          act('jump', {
                            name: spawner.name,
                          })
                        }
                      />
                      <Button
                        content="Spawn"
                        onClick={() =>
                          act('spawn', {
                            name: spawner.name,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                }>
                <LabeledList>
                  <LabeledList.Item label="Origin">
                    {spawner.you_are_text || 'Unknown'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Directives">
                    {spawner.flavor_text || 'None'}
                  </LabeledList.Item>
                  <LabeledList.Item color="bad" label="Conditions">
                    {spawner.important_text || 'None'}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

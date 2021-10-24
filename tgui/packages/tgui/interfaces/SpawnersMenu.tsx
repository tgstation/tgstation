import { useBackend } from '../backend';
import { Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type SpawnersMenuContext = {
  spawners: spawner[];
};

type spawner = {
  name: string;
  amount_left: number;
  short_desc: string;
  flavor_text: string;
  important_info?: string;
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
                /** Capitalizes the spawner name */
                title={`${spawner.name.replace(/^\w/, (c) =>
                  c.toUpperCase()
                )} (${spawner.amount_left} left)`}
                buttons={
                  <>
                    <Button
                      content="Jump"
                      onClick={() =>
                        act('jump', {
                          name: spawner.name,
                        })}
                    />
                    <Button
                      content="Spawn"
                      onClick={() =>
                        act('spawn', {
                          name: spawner.name,
                        })}
                    />
                  </>
                }>
                <LabeledList>
                  <LabeledList.Item
                    label="Setting"
                    content={spawner.short_desc}
                  />
                  <LabeledList.Item
                    label="Objectives"
                    content={spawner.flavor_text}
                  />
                  <LabeledList.Item
                    label="Conditions"
                    content={spawner.important_info}
                  />
                </LabeledList>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

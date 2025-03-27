import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

type Data = {
  spawners: Spawner[];
};

type Spawner = {
  name: string;
  amount_left: number;
  infinite: BooleanLike;
} & Partial<{
  desc: string;
  you_are_text: string;
  flavor_text: string;
  important_text: string;
}>;

export const SpawnersMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const { spawners = [] } = data;

  return (
    <Window title="Spawners Menu" width={700} height={525}>
      <Window.Content scrollable>
        <Stack vertical>
          {spawners.map((spawner) => (
            <Stack.Item key={spawner.name}>
              <Section
                fill
                // Capitalizes the spawner name
                title={capitalizeAll(spawner.name)}
                buttons={
                  <Stack>
                    {spawner.infinite ? (
                      <Stack.Item fontSize="14px" color="green">
                        Infinite
                      </Stack.Item>
                    ) : (
                      <Stack.Item fontSize="14px" color="green">
                        {spawner.amount_left} left
                      </Stack.Item>
                    )}
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
                }
              >
                <LabeledList>
                  {spawner.desc ? (
                    <LabeledList.Item label="Description">
                      {spawner.desc}
                    </LabeledList.Item>
                  ) : (
                    <div>
                      <LabeledList.Item label="Origin">
                        {spawner.you_are_text || 'Unknown'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Directives">
                        {spawner.flavor_text || 'None'}
                      </LabeledList.Item>
                      <LabeledList.Item color="bad" label="Conditions">
                        {spawner.important_text || 'None'}
                      </LabeledList.Item>
                    </div>
                  )}
                </LabeledList>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

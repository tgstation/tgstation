import { createSearch, toTitleCase } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Button, Flex, Image, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

type Ores = {
  id: string;
  name: string;
  amount: number;
};

type Ore_images = {
  name: string;
  icon: string;
};

type Data = {
  ores: Ores[];
  ore_images: Ore_images[];
};

export const OreContainer = (props) => {
  const { act, data } = useBackend<Data>();
  const { ores = [] } = data;
  const [searchItem, setSearchItem] = useState('');
  const search = createSearch(searchItem, (ore: Ores) => ore.name);
  const ores_filtered =
    searchItem.length > 0 ? ores.filter((ore) => search(ore)) : ores;

  return (
    <Window title="Ore Container" width={550} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Input
                autoFocus
                position="relative"
                mt={0.5}
                bottom="5%"
                height="20px"
                width="150px"
                placeholder="Search Ore..."
                value={searchItem}
                onInput={(e, value) => {
                  setSearchItem(value);
                }}
                fluid
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Stock" fill scrollable>
              <Stack wrap>
                {ores_filtered.map((ore) => (
                  <Flex.Item key={ore.id}>
                    <Flex direction="column" m={0.5} textAlign="center">
                      <Flex.Item>
                        <RetrieveIcon ore={ore} />
                      </Flex.Item>
                      <Flex.Item>
                        <Orename ore_name={toTitleCase(ore.name)} />
                      </Flex.Item>
                      <Flex.Item>Amount: {ore.amount}</Flex.Item>
                      <Flex.Item>
                        <Button
                          content="Withdraw"
                          color="transparent"
                          onClick={() =>
                            act('withdraw', {
                              reference: ore.id,
                            })
                          }
                        />
                      </Flex.Item>
                    </Flex>
                  </Flex.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RetrieveIcon = (props) => {
  const { data } = useBackend<Data>();
  const { ore_images = [] } = data;
  const { ore } = props;

  let icon_display = ore_images.find((icon) => icon.name === ore.name);

  if (!icon_display) {
    return null;
  }

  return (
    <Image
      m={1}
      src={`data:image/jpeg;base64,${icon_display.icon}`}
      height="64px"
      width="64px"
      style={{
        verticalAlign: 'middle',
      }}
    />
  );
};

const Orename = (props) => {
  const { ore_name } = props;
  const return_name = ore_name.split(' ');
  if (return_name.length === 0) {
    return null;
  }
  return return_name[0];
};

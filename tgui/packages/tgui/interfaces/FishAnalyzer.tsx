import { createSearch, toTitleCase } from 'common/string';
import { useState } from 'react';
import { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Button,
  Flex,
  Image,
  Input,
  Section,
  Stack,
  ProgressBar,
  Icon,
  DmIcon,
} from '../components';
import { Window } from '../layouts';

type fishData = {
  fish_name: string;
  fish_icon: string;
  fish_icon_state: string;
  fish_health: number;
  fish_size: number;
  fish_weight: number;
  fish_food: string;
  fish_food_color: string;
  fish_min_temp: number;
  fish_max_temp: number;
  fish_hunger: number;
  fish_fluid_compatible: BooleanLike;
  fish_fluid_type: string;
  fish_breed_timer: number;
  fish_traits: traitData[];
  fish_evolutions: evolutionData[];
};

type traitData = {
  trait_name: string;
  trait_desc: string;
  trait_inherit: number;
};

type evolutionData = {
  evolution_name: string;
  evolution_icon: string;
  evolution_icon_state: string;
  evolution_probability: number;
  evolution_conditions: string;
};

type Data = {
  fish_list: fishData[];
};

export const FishAnalyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const { fish_list = [] } = data;
  const [searchItem, setSearchItem] = useState('');

  return (
    <Window title="Fish Analyzer" width={700} height={400}>
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
            <Section title="Fishes" fill scrollable>
              <Stack wrap>
                {fish_list.map((fish, index) => (
                  <Stack.Item grow key={index}>
                    <Stack vertical>
                      <Stack.Item>
                        <Flex>
                          <Flex.Item>
                            <Stack vertical>
                              <Stack.Item>
                                <DmIcon
                                  icon={fish.fish_icon}
                                  icon_state={fish.fish_icon_state}
                                  height="32px"
                                  width="32px"
                                />
                              </Stack.Item>
                              <Stack.Item>{fish.fish_weight}kg</Stack.Item>
                              <Stack.Item>{fish.fish_size}cm</Stack.Item>
                            </Stack>
                          </Flex.Item>
                          <Flex.Item>
                            <Stack vertical>
                              <Stack.Item style={{ fontSize: '24px' }}>
                                {fish.fish_name}
                              </Stack.Item>
                              <Stack.Item
                                style={{
                                  borderRadius: '1em',
                                  background: fish.fish_food_color,
                                  color: 'white',
                                }}
                              >
                                {fish.fish_food}
                              </Stack.Item>
                              <Stack.Item>
                                <Stack vertical>
                                  {fish.fish_traits.map((trait, index) => (
                                    <Stack.Item key={index}>
                                      <Button
                                        color="transparent"
                                        tooltip={
                                          <Stack vertical>
                                            <Stack.Item>
                                              Inheritance: {trait.trait_inherit}
                                            </Stack.Item>
                                            <Stack.Item>
                                              {trait.trait_desc}
                                            </Stack.Item>
                                          </Stack>
                                        }
                                      >
                                        {trait.trait_name}
                                      </Button>
                                    </Stack.Item>
                                  ))}
                                </Stack>
                              </Stack.Item>
                            </Stack>
                          </Flex.Item>
                          <Flex.Item>
                            <Stack vertical>
                              <Stack.Item>
                                Health:{' '}
                                <ProgressBar
                                  value={fish.fish_health / 100}
                                  ranges={{
                                    good: [0.9, Infinity],
                                    average: [0.5, 0.9],
                                    bad: [-Infinity, 0.5],
                                  }}
                                ></ProgressBar>
                              </Stack.Item>
                              <Stack.Item>
                                Hunger:{' '}
                                <ProgressBar
                                  value={fish.fish_hunger / 100}
                                  ranges={{
                                    good: [0.9, Infinity],
                                    average: [0.5, 0.9],
                                    bad: [-Infinity, 0.5],
                                  }}
                                ></ProgressBar>
                              </Stack.Item>
                            </Stack>
                          </Flex.Item>
                        </Flex>
                      </Stack.Item>
                      <Stack.Item>
                        <Flex>
                          <Flex.Item>
                            {fish.fish_min_temp}-{fish.fish_max_temp}
                          </Flex.Item>
                          <Flex.Item
                            style={{
                              color: fish.fish_fluid_compatible
                                ? 'green'
                                : 'red',
                            }}
                          >
                            {fish.fish_fluid_type}
                          </Flex.Item>
                          <Flex.Item>
                            <Stack vertical>
                              {fish.fish_evolutions.map((evolution, index) => (
                                <Stack.Item key={index}>
                                  <Flex>
                                    <Flex.Item>
                                      <DmIcon
                                        icon={fish.fish_icon}
                                        icon_state={fish.fish_icon_state}
                                        height="32px"
                                        width="32px"
                                      />
                                    </Flex.Item>
                                    <Flex.Item>
                                      {evolution.evolution_probability}
                                      <Icon
                                        color={'#642600'}
                                        name={'arrow-left'}
                                      />
                                    </Flex.Item>
                                    <Flex.Item>
                                      <DmIcon
                                        icon={evolution.evolution_icon}
                                        icon_state={
                                          evolution.evolution_icon_state
                                        }
                                        height="32px"
                                        width="32px"
                                      />
                                    </Flex.Item>
                                  </Flex>
                                </Stack.Item>
                              ))}
                            </Stack>
                          </Flex.Item>
                        </Flex>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

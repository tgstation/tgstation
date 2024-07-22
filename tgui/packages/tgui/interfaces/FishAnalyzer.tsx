import { createSearch } from 'common/string';
import { useState } from 'react';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Flex,
  Icon,
  Input,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type FishData = {
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
  fish_suitable_temp: BooleanLike;
  fish_breed_timer: number;
  fish_traits: TraitData[];
  fish_evolutions: EvolutionData[];
};

type TraitData = {
  trait_name: string;
  trait_desc: string;
  trait_inherit: number;
};

type EvolutionData = {
  evolution_name: string;
  evolution_icon: string;
  evolution_icon_state: string;
  evolution_probability: number;
  evolution_conditions: string;
};

type Data = {
  fish_list: FishData[];
  fish_scanned: BooleanLike;
};

export const FishAnalyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const { fish_list = [], fish_scanned } = data;
  const [searchText, setSearchText] = useState('');

  const search = createSearch(searchText, (fish: FishData) => fish.fish_name);

  const fish_filtered =
    searchText.length > 0 ? fish_list.filter(search) : fish_list;

  return (
    <Window
      title="Fish Analyzer"
      width={fish_scanned ? 530 : 700}
      height={fish_scanned ? 270 : 460}
    >
      <Window.Content
        style={{
          background: '#402784',
        }}
      >
        <Stack fill vertical>
          {!fish_scanned && (
            <Stack.Item>
              <Section>
                <Input
                  autoFocus
                  position="relative"
                  mt={0.5}
                  bottom="5%"
                  height="20px"
                  width="150px"
                  placeholder="Search Fish..."
                  value={searchText}
                  onInput={(e, value) => {
                    setSearchText(value);
                  }}
                  fluid
                />
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section title="Fish" fill scrollable>
              <Stack wrap>
                {fish_filtered.map((fish, index) => (
                  <Stack.Item
                    position="relative"
                    mt={2}
                    ml={2}
                    width={fish_scanned ? '100%' : '44%'}
                    minHeight="120px"
                    key={index}
                    style={{
                      padding: '5px 5px',
                      background: 'linear-gradient(to right,#2e0b64, #47218e)',
                      borderRadius: '1em',
                      border: '3px solid #6f1d94',
                    }}
                  >
                    <FishItem fish={fish} />
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

const FishItem = (props) => {
  const { fish } = props;

  return (
    <Stack vertical>
      <Stack.Item minHeight="105px">
        <Flex>
          <Flex.Item width="40px">
            <Stack vertical>
              <Stack.Item>
                <DmIcon
                  style={{ background: '#1a0940' }}
                  icon={fish.fish_icon}
                  icon_state={fish.fish_icon_state}
                  height="40px"
                  width="40px"
                />
              </Stack.Item>
              <Stack.Item style={{ fontSize: '10px' }}>
                {fish.fish_weight}g
              </Stack.Item>
              <Stack.Item style={{ fontSize: '10px' }}>
                {fish.fish_size}cm
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item grow ml={1}>
            <Stack vertical>
              <Stack.Item style={{ fontSize: '13px', fontWeight: 'bold' }}>
                {dissectName(fish.fish_name).toUpperCase()}
              </Stack.Item>
              <Stack.Item
                ml={1}
                textAlign="center"
                style={{
                  borderRadius: '1em',
                  background: fish.fish_food_color,
                  color: 'white',
                }}
              >
                {fish.fish_food}
              </Stack.Item>
              <Stack.Item mt={2}>
                {fish.fish_traits.length === 0 ? (
                  <Button color="transparent" tooltip="Fish has no traits!">
                    None
                  </Button>
                ) : (
                  <Stack vertical>
                    {fish.fish_traits.map((trait, index) => (
                      <Stack.Item mt={-1} key={index}>
                        <Button
                          color="transparent"
                          tooltip={
                            <Stack vertical>
                              <Stack.Item>
                                Inheritance: {trait.trait_inherit}
                              </Stack.Item>
                              <Stack.Item>{trait.trait_desc}</Stack.Item>
                            </Stack>
                          }
                        >
                          {trait.trait_name}
                        </Button>
                      </Stack.Item>
                    ))}
                  </Stack>
                )}
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item grow ml={2}>
            <Stack vertical>
              <Stack.Item>
                Health:{' '}
                <ProgressBar
                  width="95%"
                  value={fish.fish_health / 100}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.5, 0.9],
                    bad: [-Infinity, 0.5],
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                Hunger:{' '}
                <ProgressBar
                  width="95%"
                  value={fish.fish_hunger / 100}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.5, 0.9],
                    bad: [-Infinity, 0.5],
                  }}
                />
              </Stack.Item>
              <Stack.Item mt={2}>
                {fish.fish_evolutions.length === 0 ? (
                  <Box mb={2}>No evolutions!</Box>
                ) : (
                  <Stack mt={-2} vertical>
                    {fish.fish_evolutions.map((evolution, index) => (
                      <Stack.Item key={index}>
                        <EvolutionItem evolution={evolution} fish={fish} />
                      </Stack.Item>
                    ))}
                  </Stack>
                )}
              </Stack.Item>
            </Stack>
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item>
        <Flex>
          <Flex.Item
            width="25%"
            grow
            style={{
              color: fish.fish_suitable_temp ? '#1ac400' : 'red',
            }}
          >
            {fish.fish_min_temp}k - {fish.fish_max_temp}k
          </Flex.Item>
          <Flex.Item
            ml={3}
            grow
            style={{
              color: fish.fish_fluid_compatible ? '#1ac400' : 'red',
            }}
          >
            {dissectName(fish.fish_fluid_type)}
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};

const EvolutionItem = (props) => {
  const { evolution, fish } = props;

  return (
    <Flex>
      <Flex.Item mt={1}>
        <DmIcon
          icon={fish.fish_icon}
          icon_state={fish.fish_icon_state}
          height="32px"
          width="32px"
        />
      </Flex.Item>
      <Flex.Item>
        <Stack ml={0.5} vertical align="center">
          <Stack.Item mt={2} style={{ fontSize: '8px' }}>
            {evolution.evolution_probability}%
          </Stack.Item>
          <Stack.Item mt={-0.2}>
            <Icon style={{ fontSize: '15px' }} color="red" name="arrow-right" />
          </Stack.Item>
        </Stack>
      </Flex.Item>
      <Flex.Item>
        <DmIcon
          mt={1}
          icon={evolution.evolution_icon}
          icon_state={evolution.evolution_icon_state}
          height="32px"
          width="32px"
        />
      </Flex.Item>
    </Flex>
  );
};

function dissectName(input: string): string {
  return input.split(' ')[0].slice(0, 12);
}

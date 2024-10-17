import { capitalizeFirst } from 'common/string';
import {
  Box,
  Button,
  DmIcon,
  Flex,
  Icon,
  Knob,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  temperature: number;
  fluidType: string;
  minTemperature: number;
  maxTemperature: number;
  fluidTypes: string[];
  fishData: FishData[];
  propData: PropData[];
  allowBreeding: BooleanLike;
  feedingInterval: number;
  heartIcon: string;
  heartIconState: string;
  heartEmptyIconState: string;
};

type FishData = {
  fish_ref: string;
  fish_name: string;
  fish_happiness: number;
  fish_icon: string;
  fish_icon_state: string;
  fish_health: number;
};

type PropData = {
  prop_ref: string;
  prop_name: string;
  prop_icon: string;
  prop_icon_state: string;
};

export const Aquarium = (props) => {
  const { act, data } = useBackend<Data>();
  const { fishData } = data;

  return (
    <Window width={765} height={500} theme="ntos">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Settings />
          </Stack.Item>
          <Stack.Item grow>
            <Flex>
              <Flex.Item height="300px" width="75%">
                <Section fill title="Fish" scrollable>
                  <Stack wrap>
                    {fishData.map((fish) => (
                      <Stack.Item
                        width="44%"
                        height="100px"
                        ml={1}
                        key={fish.fish_ref}
                        style={{
                          background: 'rgba(36, 50, 67, 0.5)',
                          padding: '5px 5px',
                          borderRadius: '1em',
                          border: '3px solid #574e82',
                        }}
                      >
                        <FishInfo fish={fish} />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Flex.Item>
              <Flex.Item ml={1} grow>
                <PropTypes />
              </Flex.Item>
            </Flex>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const FishInfo = (props) => {
  const { act, data } = useBackend<Data>();
  const { fish } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        <Flex>
          <Flex.Item width="40px">
            <DmIcon
              style={{ borderRadius: '1em', background: '#151326' }}
              icon={fish.fish_icon}
              icon_state={fish.fish_icon_state}
              height="40px"
              width="40px"
            />
          </Flex.Item>
          <Flex.Item grow>
            <Stack vertical>
              <Stack.Item
                ml={1}
                style={{ fontSize: '13px', fontWeight: 'bold' }}
              >
                {fish.fish_name.toUpperCase()}
              </Stack.Item>
              <Stack.Item mt={fish.fish_health > 0 ? -4 : 1}>
                {(fish.fish_health > 0 && (
                  <CalculateHappiness happiness={fish.fish_happiness} />
                )) || <Icon ml={2} name="skull-crossbones" textColor="white" />}
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item>
            <Flex>
              <Button
                fluid
                icon="arrow-up"
                color="transparent"
                onClick={() =>
                  act('remove_item', {
                    item_reference: fish.fish_ref,
                  })
                }
              />
            </Flex>
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow>
        <Flex>
          <Flex.Item width="50%">
            <Button
              textAlign="center"
              mt={1}
              fluid
              color="transparent"
              icon="paw"
              style={{
                padding: '3px',
                borderRadius: '1em',
                background: '#151326',
              }}
              onClick={() =>
                act('pet_fish', {
                  fish_reference: fish.fish_ref,
                })
              }
            >
              Pet
            </Button>
          </Flex.Item>
          <Flex.Item width="50%">
            <Button.Input
              textAlign="center"
              mt={1}
              ml={1}
              fluid
              placeholder="Rename"
              color="transparent"
              onCommit={(e, value) => {
                act('rename_fish', {
                  fish_reference: fish.fish_ref,
                  chosen_name: value,
                });
              }}
              style={{
                padding: '3px',
                borderRadius: '1em',
                background: '#151326',
              }}
            >
              <Flex>
                <Flex.Item ml={3}>
                  <Icon name="keyboard" />
                </Flex.Item>
                <Flex.Item ml={1}>Rename</Flex.Item>
              </Flex>
            </Button.Input>
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};

const PropTypes = (props) => {
  const { act, data } = useBackend<Data>();
  const { propData } = data;

  return (
    <Section scrollable fill title="Props">
      <Stack vertical>
        {propData.map((prop) => (
          <Stack.Item className="candystripe" key={prop.prop_ref}>
            <Button
              fluid
              color="transparent"
              onClick={() =>
                act('remove_item', {
                  item_reference: prop.prop_ref,
                })
              }
            >
              <Flex>
                <Flex.Item>
                  <DmIcon
                    icon={prop.prop_icon}
                    icon_state={prop.prop_icon_state}
                    height="40px"
                    width="40px"
                  />
                </Flex.Item>
                <Flex.Item
                  ml={1}
                  mt={1}
                  style={{ fontSize: '11px', fontWeight: 'bold' }}
                >
                  {capitalizeFirst(prop.prop_name)}
                </Flex.Item>
              </Flex>
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const CalculateHappiness = (props) => {
  const { data } = useBackend<Data>();
  const { heartIcon } = data;
  const { happiness } = props;

  return (
    <Box>
      {Array.from({ length: 5 }, (_, index) => (
        <DmIcon
          key={index}
          ml={index === 0 ? 0 : -6}
          icon={heartIcon}
          icon_state={happiness >= index ? 'full_heart' : 'empty_heart'}
          height="48px"
          width="48px"
        />
      ))}
    </Box>
  );
};

const Settings = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    temperature,
    minTemperature,
    maxTemperature,
    fluidTypes,
    fluidType,
    allowBreeding,
    feedingInterval,
  } = data;

  return (
    <Flex fill>
      <Flex.Item grow>
        <Section fill title="Temperature">
          <Knob
            mt={3}
            size={1.5}
            mb={1}
            value={temperature}
            unit="K"
            minValue={minTemperature}
            maxValue={maxTemperature}
            step={1}
            stepPixelSize={1}
            onDrag={(_, value) =>
              act('temperature', {
                temperature: value,
              })
            }
          />
        </Section>
      </Flex.Item>
      <Flex.Item ml={1} grow>
        <Section fill title="Fluid">
          <Flex direction="column" mb={1}>
            {fluidTypes.map((f) => (
              <Flex.Item className="candystripe" key={f}>
                <Button
                  textAlign="center"
                  fluid
                  color="transparent"
                  selected={fluidType === f}
                  onClick={() => act('fluid', { fluid: f })}
                >
                  {f}
                </Button>
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Flex.Item>
      <Flex.Item ml={1} grow>
        <Section fill title="Settings">
          <Box mt={2}>
            <LabeledList>
              <LabeledList.Item label="Reproduction/Growth">
                <Button
                  textAlign="center"
                  width="75px"
                  content={allowBreeding ? 'Online' : 'Offline'}
                  selected={allowBreeding}
                  onClick={() => act('allow_breeding')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Feeding Interval">
                <NumberInput
                  width="15px"
                  value={feedingInterval}
                  minValue={1}
                  maxValue={7}
                  step={1}
                  unit="minutes"
                  onChange={(value) =>
                    act('feeding_interval', {
                      feeding_interval: value,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
      </Flex.Item>
    </Flex>
  );
};
function dissectName(input: string): string {
  return input.split(' ')[0].slice(0, 18);
}

import { BooleanLike } from 'common/react';
import { capitalize } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Image,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  currently_summoned: BooleanLike;
  pet_state: string;
  hunger: number;
  current_exp: number;
  steps_counter: number;
  required_exp: number;
  happiness: number;
  pet_area: string;
  maximum_happiness: number;
  maximum_hunger: number;
  level: number;
  preview_icon: string;
  pet_color: string;
  pet_hat: string;
  pet_name: string;
  selected_area: string;
  can_reroll: BooleanLike;
  pet_gender: string;
  in_dropzone: BooleanLike;
  can_summon: BooleanLike;
  can_alter_appearance: BooleanLike;
  possible_emotes: string[];
  pet_state_icons: Pet_State_Icons[];
  hat_selections: Hat_Selections[];
  possible_colors: Possible_Colors[];
  pet_updates: Pet_Updates[];
};

type Pet_State_Icons = {
  name: string;
  icon: string;
};

type Hat_Selections = {
  hat_id: string;
  hat_name: string;
};

type Possible_Colors = {
  color_name: string;
  color_value: string;
};

type Pet_Updates = {
  update_id: number;
  update_name: string;
  update_picture: string;
  update_message: string;
  update_likers: number;
  update_already_liked: BooleanLike;
};

enum Tab {
  Stats,
  Customization,
  Updates,
  Tricks,
}

enum PetGender {
  male = 'male',
  female = 'female',
  neuter = 'neuter',
}

export const NtosVirtualPet = (props) => {
  const [tab, setTab] = useState(Tab.Stats);

  return (
    <NtosWindow width={390} height={570}>
      <NtosWindow.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === Tab.Stats}
            onClick={() => setTab(Tab.Stats)}
          >
            Stats
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === Tab.Customization}
            onClick={() => setTab(Tab.Customization)}
          >
            Customization
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === Tab.Updates}
            onClick={() => setTab(Tab.Updates)}
          >
            Pet Updates
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === Tab.Tricks}
            onClick={() => setTab(Tab.Tricks)}
          >
            Tricks
          </Tabs.Tab>
        </Tabs>
        {tab === Tab.Stats && <Stats />}
        {tab === Tab.Customization && <Customization />}
        {tab === Tab.Updates && <AllPetUpdates />}
        {tab === Tab.Tricks && <PetTricks />}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const Stats = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    currently_summoned,
    pet_state,
    hunger,
    current_exp,
    required_exp,
    happiness,
    maximum_happiness,
    maximum_hunger,
    level,
    pet_area,
    steps_counter,
    selected_area,
    can_reroll,
    can_summon,
    in_dropzone,
  } = data;
  return (
    <>
      <Section title="Pet Stats">
        <Flex>
          <Flex.Item>
            <PetIcon our_pet_state={pet_state} />
          </Flex.Item>
          <Flex.Item>
            <Stack vertical position="absolute" right={1}>
              <Stack.Item>Current Level: {level}</Stack.Item>
              <Stack.Item mt={3}>
                Happiness:
                <ProgressBar
                  value={happiness}
                  maxValue={maximum_happiness}
                  color="white"
                />
              </Stack.Item>
              <Stack.Item>
                Exp Progress:
                <ProgressBar
                  value={current_exp}
                  maxValue={required_exp}
                  color="white"
                />
              </Stack.Item>
              <Stack.Item>
                Hunger:
                <ProgressBar
                  value={hunger}
                  maxValue={maximum_hunger}
                  color="white"
                />
              </Stack.Item>
            </Stack>
          </Flex.Item>
        </Flex>
      </Section>
      <Section title="Pet Location" style={{ padding: '5px' }}>
        <Stack>
          <Stack.Item grow>{pet_area}</Stack.Item>
          <Stack.Item>
            <Button
              disabled={!can_summon}
              style={{ padding: '3px' }}
              onClick={() => act('summon_pet')}
            >
              {currently_summoned ? 'Recall' : 'Release'}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Stack fill>
        <Stack.Item grow>
          <Section title="Pet Feed Dropzone">
            <Stack>
              <Stack.Item grow>{selected_area}</Stack.Item>
              <Stack.Item>
                {(in_dropzone && (
                  <Button
                    style={{ padding: '3px' }}
                    onClick={() => act('drop_feed')}
                  >
                    Get Food
                  </Button>
                )) || (
                  <Button
                    style={{ padding: '3px' }}
                    disabled={!can_reroll}
                    onClick={() => act('get_feed_location')}
                  >
                    {selected_area === 'No location set'
                      ? 'Generate'
                      : 'Reroll'}
                  </Button>
                )}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Section
            fontWeight="bold"
            fontSize="15px"
            style={{ padding: '20px' }}
          >
            {' '}
            Steps: {steps_counter}
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
};

const PetTricks = (props) => {
  const { act, data } = useBackend<Data>();
  const { possible_emotes } = data;
  const [sequences, setSequences] = useState(['none', 'none', 'none', 'none']);
  const [TrickName, setTrickName] = useState('Trick');

  const UpdateSequence = (Index: number, Trick: string) => {
    const NewSequence = [...sequences];
    NewSequence[Index] = Trick;
    setSequences(NewSequence);
  };

  return (
    <Section
      title={capitalize(TrickName)}
      buttons={
        <Button.Input
          color="transparent"
          onCommit={(_, value) => setTrickName(value)}
        >
          Rename Trick
        </Button.Input>
      }
    >
      <LabeledList>
        {sequences.map((sequence, index) => (
          <LabeledList.Item key={index} label={`Sequence ${index + 1}`}>
            <Dropdown
              width="50%"
              selected={sequences[index]}
              options={possible_emotes}
              onSelected={(selected) => UpdateSequence(index, selected)}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
      <Button
        position="relative"
        left="80%"
        width="20%"
        textAlign="center"
        fluid
        onClick={() =>
          act('teach_tricks', {
            trick_name: TrickName,
            tricks: sequences,
          })
        }
      >
        Teach
      </Button>
    </Section>
  );
};

const Customization = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    preview_icon,
    hat_selections = [],
    possible_colors = [],
    pet_hat,
    pet_color,
    pet_name,
    pet_gender,
    can_alter_appearance,
  } = data;

  const hatSelectionList = {};
  for (const index in hat_selections) {
    const hat = hat_selections[index];
    hatSelectionList[hat.hat_name] = hat;
  }

  const possibleColorList = {};
  for (const index in possible_colors) {
    const color = possible_colors[index];
    possibleColorList[color.color_name] = color;
  }

  const [selectedHat, setSelectedHat] = useState(hatSelectionList[pet_hat]);
  const [selectedGender, setSelectedGender] = useState(pet_gender);
  const [selectedName, setSelectedName] = useState(pet_name);
  const [selectedColor, setSelectedColor] = useState(
    possibleColorList[pet_color],
  );
  return (
    <>
      <Section title="Pet Preview" textAlign="center">
        <Image
          m={1}
          src={`data:image/jpeg;base64,${preview_icon}`}
          height="160px"
          width="160px"
          style={{
            verticalAlign: 'middle',
            borderRadius: '1em',
            border: '1px solid white',
          }}
        />
      </Section>
      <Stack>
        <Stack.Item width="50%">
          <Section title="Pet Name">
            <Input
              fluid
              maxLength={30}
              value={selectedName}
              onInput={(_, value) => setSelectedName(value)}
            />
          </Section>
        </Stack.Item>
        <Stack.Item width="50%">
          <Section title="Pet Hat">
            <Dropdown
              selected={selectedHat?.hat_name}
              options={hat_selections.map((selected_hat) => {
                return selected_hat.hat_name;
              })}
              onSelected={(selected) =>
                setSelectedHat(hatSelectionList[selected])
              }
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack mt={0.5}>
        <Stack.Item width="50%">
          <Section title="Pet Color">
            <Dropdown
              selected={selectedColor?.color_name}
              options={possible_colors.map((possible_color) => {
                return possible_color.color_name;
              })}
              onSelected={(selected) =>
                setSelectedColor(possibleColorList[selected])
              }
            />
          </Section>
        </Stack.Item>
        <Stack.Item width="50%">
          <Section title="Pet Gender">
            <Stack>
              <Stack.Item grow>
                <Button
                  selected={selectedGender === PetGender.male}
                  icon="mars"
                  onClick={() => setSelectedGender(PetGender.male)}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  selected={selectedGender === PetGender.female}
                  icon="venus"
                  onClick={() => setSelectedGender(PetGender.female)}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  selected={selectedGender === PetGender.neuter}
                  icon="neuter"
                  onClick={() => setSelectedGender(PetGender.neuter)}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
      <Section textAlign="center" mt={2}>
        <Button
          mt={-1}
          style={{ padding: '3px' }}
          disabled={!can_alter_appearance}
          onClick={() =>
            act('apply_customization', {
              chosen_hat: selectedHat?.hat_id,
              chosen_name: selectedName,
              chosen_color: selectedColor?.color_value,
              chosen_gender: selectedGender,
            })
          }
        >
          Apply
        </Button>
      </Section>
    </>
  );
};

const AllPetUpdates = (props) => {
  const { act, data } = useBackend<Data>();
  const { pet_updates } = data;

  return (
    <Section title="Pet Updates" fill>
      <Stack vertical>
        {pet_updates.map((update) => (
          <Stack.Item key={update.update_id} mt={3}>
            <Box
              textAlign="center"
              style={{ borderRadius: '1em', border: '1px solid white' }}
            >
              <Flex>
                <Flex.Item
                  width="25%"
                  style={{
                    borderRight: '1px solid white',
                  }}
                >
                  <Stack vertical>
                    <Stack.Item>
                      {update.update_name.substring(0, 6)}
                    </Stack.Item>
                    <Stack.Item>
                      <Image
                        mt={-3}
                        src={`data:image/jpeg;base64,${update.update_picture}`}
                        height="64px"
                        width="64px"
                        style={{
                          verticalAlign: 'middle',
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Flex.Item>
                <Flex.Item style={{ padding: '10px' }} grow>
                  {update.update_name.substring(0, 6)} {update.update_message}
                  <Button
                    fluid
                    width="50px"
                    ml="75%"
                    mt="5%"
                    selected={update.update_already_liked}
                    color="transparent"
                    icon="thumbs-up"
                    onClick={() =>
                      act('like_update', {
                        update_reference: update.update_id,
                      })
                    }
                  >
                    {update.update_likers}
                  </Button>
                </Flex.Item>
              </Flex>
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const PetIcon = (props) => {
  const { data } = useBackend<Data>();
  const { pet_state_icons = [] } = data;
  const { our_pet_state } = props;

  let icon_display = pet_state_icons.find(
    (pet_icon) => pet_icon.name === our_pet_state,
  );

  if (!icon_display) {
    return null;
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Image
          m={1}
          src={`data:image/jpeg;base64,${icon_display.icon}`}
          height="160px"
          width="160px"
          style={{
            verticalAlign: 'middle',
            borderRadius: '1em',
            border: '1px solid white',
          }}
        />
      </Stack.Item>
      <Stack.Item textAlign="center">{capitalize(our_pet_state)}</Stack.Item>
    </Stack>
  );
};

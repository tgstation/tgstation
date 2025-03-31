import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Icon,
  Image,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { IconDisplay } from './LootPanel/IconDisplay';
type Data = {
  pet_name: string | null;
  pet_specie: string;
  pet_path: string;
  pet_gender: string;
  pet_types: string[];
  pet_trick_name: string;
  pet_options: PetOptions[];
  pet_carrier: string;
  carrier_options: CarrierOptions[];
  pet_possible_emotes: String[];
};

enum PetGender {
  male = 'male',
  female = 'female',
  neuter = 'neuter',
}

type CarrierOptions = {
  carrier_color: string;
  carrier_icon: string;
};

type PetOptions = {
  pet_specie: string;
  pet_name: string;
  pet_icon: string;
  pet_path: string;
  pet_icon_state: string;
};

const RetrievePet = (pet_path: string, pet_options: PetOptions[]) => {
  return pet_options.find((option) => option.pet_path === pet_path);
};

const RetrieveCarrier = (color: string, carrier_options: CarrierOptions[]) => {
  return carrier_options.find((option) => option.carrier_color === color);
};

const FilterPetList = (pet_specie: string, pet_options: PetOptions[]) => {
  return pet_options.filter((pet) => pet.pet_specie === pet_specie);
};

export const PetBuilder = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    pet_name,
    pet_path,
    pet_gender,
    pet_options,
    pet_types,
    pet_specie,
    pet_trick_name,
    carrier_options,
    pet_carrier,
    pet_possible_emotes,
  } = data;

  const [selectedCarrier, setSelectedCarrier] = useState(
    () => RetrieveCarrier(pet_carrier, carrier_options) || null,
  );
  const [sequences, setSequences] = useState(['none', 'none', 'none']);
  const [TrickName, setTrickName] = useState(pet_trick_name);

  const UpdateSequence = (Index: number, Trick: string) => {
    const NewSequence = [...sequences];
    NewSequence[Index] = Trick;
    setSequences(NewSequence);
  };

  const [selectedPath, setSelectedPath] = useState(pet_path);
  const [selectedPet, setSelectedPet] = useState(
    () => RetrievePet(selectedPath, pet_options) || null,
  );
  const [selectedSpecie, setSelectedSpecie] = useState(pet_specie);
  const [filteredPetList, setFilteredPetList] = useState(
    () => FilterPetList(selectedSpecie, pet_options) || [],
  );
  const [selectedName, setSelectedName] = useState(pet_name);
  const [selectedGender, setSelectedGender] = useState(pet_gender);

  const ScrollPetSpecies = (direction: string) => {
    let dir = direction === 'next' ? 1 : -1;
    let currindex = pet_types.indexOf(selectedSpecie);
    const newSpecie =
      pet_types[(currindex + dir + pet_types.length) % pet_types.length];

    const newFilteredPetList = FilterPetList(newSpecie, pet_options);
    setSelectedSpecie(newSpecie);
    setFilteredPetList(newFilteredPetList);
    setSelectedPet(newFilteredPetList[0]);
  };

  const ScrollPetOptions = (direction: string) => {
    if (!selectedPet) {
      return;
    }
    let dir = direction === 'next' ? 1 : -1;
    let currindex = filteredPetList.indexOf(selectedPet);
    setSelectedPet(
      filteredPetList[
        (currindex + dir + filteredPetList.length) % filteredPetList.length
      ],
    );
  };

  return (
    <Window title="Create Your Pet!" width={665} height={325}>
      <Window.Content>
        <Flex width="50%">
          <Flex.Item>
            <Stack vertical>
              <Stack.Item>
                <PetSelector
                  selectedSpecie={selectedSpecie}
                  selectedPet={selectedPet}
                  pet_types={pet_types}
                  ScrollPetSpecies={ScrollPetSpecies}
                  ScrollPetOptions={ScrollPetOptions}
                />
              </Stack.Item>
              <Stack.Item mt={1.5}>
                <Section
                  textAlign="center"
                  style={{
                    borderRadius: '1em',
                  }}
                >
                  <Button
                    color="green"
                    onClick={() =>
                      act('finalize_pet', {
                        selected_path: selectedPet?.pet_path,
                        selected_trick_name: TrickName,
                        selected_trick_moves: sequences,
                        selected_pet_name: selectedName,
                        selected_gender: selectedGender,
                        selected_specie: selectedSpecie,
                        selected_carrier: selectedCarrier?.carrier_color,
                      })
                    }
                    style={{
                      fontSize: '27px',
                      borderRadius: '1em',
                    }}
                  >
                    <Flex>
                      <Flex.Item>
                        <Icon name="paw" />
                      </Flex.Item>
                      <Flex.Item ml={1}>Finalize Pet!</Flex.Item>
                      <Flex.Item>
                        <Icon ml={1} name="paw" />
                      </Flex.Item>
                    </Flex>
                  </Button>
                </Section>
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item ml={1}>
            <Section width="350px">
              <PetDetails
                selectedName={selectedName}
                setSelectedName={setSelectedName}
                selectedGender={selectedGender}
                setSelectedGender={setSelectedGender}
              />
              <Flex>
                <Flex.Item width="70px">
                  <CarrierSelector
                    selectedCarrier={selectedCarrier}
                    carrier_options={carrier_options}
                    setSelectedCarrier={setSelectedCarrier}
                  />
                </Flex.Item>
                <Flex.Item ml={5} grow>
                  <TrickSequence
                    ml={5}
                    TrickName={TrickName}
                    pet_possible_emotes={pet_possible_emotes}
                    setTrickName={setTrickName}
                    sequences={sequences}
                    UpdateSequence={UpdateSequence}
                    carrier_options={carrier_options}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const PetSelector = ({
  selectedSpecie,
  selectedPet,
  pet_types,
  ScrollPetSpecies,
  ScrollPetOptions,
}: any) => (
  <Section>
    <Stack vertical>
      <Stack.Item>
        <Flex style={{ borderBottom: '2px solid #6f1d94' }}>
          <Flex.Item>
            <Button
              color="transparent"
              icon="arrow-left"
              style={{ fontSize: '16px' }}
              onClick={() => ScrollPetSpecies('previous')}
            />
          </Flex.Item>
          <Flex.Item grow textAlign="center" style={{ fontSize: '16px' }}>
            {selectedSpecie}
          </Flex.Item>
          <Flex.Item>
            <Button
              color="transparent"
              icon="arrow-right"
              style={{ fontSize: '16px' }}
              onClick={() => ScrollPetSpecies('next')}
            />
          </Flex.Item>
        </Flex>
      </Stack.Item>
      {selectedPet && (
        <Stack.Item mt={5}>
          <Flex>
            <Flex.Item>
              <Button
                mt={5}
                color="transparent"
                icon="arrow-left"
                style={{ fontSize: '20px' }}
                onClick={() => ScrollPetOptions('previous')}
              />
            </Flex.Item>
            <Flex.Item grow textAlign="center">
              <IconDisplay
                item={{
                  icon: selectedPet.pet_icon,
                  icon_state: selectedPet.pet_icon_state,
                  name: selectedPet.pet_name,
                  path: selectedPet.pet_path,
                  ref: selectedPet.pet_ref,
                }}
                size={{
                  height: 11,
                  width: 11,
                }}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                mt={5}
                color="transparent"
                style={{ fontSize: '20px' }}
                icon="arrow-right"
                onClick={() => ScrollPetOptions('next')}
              />
            </Flex.Item>
          </Flex>
        </Stack.Item>
      )}
    </Stack>
  </Section>
);

const PetDetails = ({
  selectedName,
  setSelectedName,
  selectedGender,
  setSelectedGender,
}: any) => (
  <Stack vertical width="85%">
    <Flex style={{ borderBottom: '1px solid gray' }}>
      <Flex.Item>
        <Stack vertical>
          <Stack.Item style={{ fontSize: '16px' }}>Pet Name</Stack.Item>
          <Stack.Item>
            <Input
              mb={2}
              ml={2}
              mt={0.5}
              width="220px"
              maxLength={30}
              value={selectedName}
              onInput={(_, value) => setSelectedName(value)}
              style={{ borderRadius: '1em' }}
            />
          </Stack.Item>
        </Stack>
      </Flex.Item>
      <Flex.Item>
        <Icon
          style={{ transform: 'rotate(30deg)', fontSize: '30px' }}
          ml={8}
          mt={1}
          name="paw"
        />
      </Flex.Item>
    </Flex>
    <Stack.Item>
      <Stack vertical>
        <Stack.Item style={{ fontSize: '16px' }}>Pet Gender</Stack.Item>
        <Stack.Item>
          <Stack mt={0.5} style={{ borderBottom: '1px solid gray' }}>
            <Stack.Item grow ml={2} mb={2}>
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
        </Stack.Item>
      </Stack>
    </Stack.Item>
  </Stack>
);

const TrickSequence = ({
  TrickName,
  setTrickName,
  sequences,
  pet_possible_emotes,
  UpdateSequence,
  carrier_options,
}: any) => (
  <Section
    mt={1}
    width="80%"
    style={{ borderBottom: '0px solid #6f1d94' }}
    title={TrickName}
    buttons={
      <Button.Input
        color="transparent"
        onCommit={(_, value) => setTrickName(value)}
      >
        Rename
      </Button.Input>
    }
  >
    <Box ml={2}>
      <LabeledList>
        {sequences.map((sequence: string, index: number) => (
          <LabeledList.Item key={index} label={`Move ${index + 1}`}>
            <Dropdown
              width="80%"
              selected={sequences[index]}
              options={pet_possible_emotes}
              onSelected={(selected: string) => UpdateSequence(index, selected)}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Box>
  </Section>
);

const CarrierSelector = ({
  selectedCarrier,
  carrier_options,
  setSelectedCarrier,
}: any) => (
  <Flex grow>
    <Flex.Item width="30%">
      <Stack vertical>
        <Stack.Item>
          <Image
            m={1}
            src={`data:image/jpeg;base64,${selectedCarrier?.carrier_icon}`}
            height="64px"
            width="64px"
            style={{ verticalAlign: 'middle' }}
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            width="70px"
            selected={selectedCarrier?.carrier_color}
            options={carrier_options.map(
              (carrier: any) => carrier.carrier_color,
            )}
            onSelected={(selected: string) => {
              const new_carrier = RetrieveCarrier(selected, carrier_options);
              if (new_carrier) {
                setSelectedCarrier(new_carrier);
              }
            }}
          />
        </Stack.Item>
      </Stack>
    </Flex.Item>
  </Flex>
);

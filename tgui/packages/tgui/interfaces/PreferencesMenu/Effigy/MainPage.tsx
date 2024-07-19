import { filter, map, sortBy } from 'common/collections';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useState } from 'react';

import { sendAct, useBackend } from '../../../backend';
import {
  Autofocus,
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  Popper,
  Stack,
} from '../../../components';
import { CharacterPreview } from '../../common/CharacterPreview';
import {
  createSetPreference,
  PreferencesMenuData,
  RandomSetting,
  ServerData,
} from '../data';
import { MultiNameInput, NameInput } from '../names';
import features from '../preferences/features';
import {
  FeatureChoicedServerData,
  FeatureValueInput,
} from '../preferences/features/base';
import { Gender, GENDERS } from '../preferences/gender';
import { RandomizationButton } from '../RandomizationButton';
import { ServerPreferencesFetcher } from '../ServerPreferencesFetcher';
import { useRandomToggleState } from '../useRandomToggleState';

const CLOTHING_CELL_SIZE = 72;
const CLOTHING_SIDEBAR_ROWS = 8.05;

const CLOTHING_SELECTION_CELL_SIZE = 72;
const CLOTHING_SELECTION_CELL_SIZE_HORIZONTAL = 96;
const CLOTHING_SELECTION_CELL_SIZE_VERTICAL = 135;
const ENTRIES_PER_ROW = 4;
const MAX_ROWS = 2.8;
const CLOTHING_SELECTION_WIDTH = 5.6;
const CLOTHING_SELECTION_MULTIPLIER = 5.3;

const CharacterControls = (props: {
  handleRotate: () => void;
  handleOpenSpecies: () => void;
  handleLoadout: () => void;
  gender: Gender;
  setGender: (gender: Gender) => void;
  showGender: boolean;
}) => {
  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={props.handleRotate}
          fontSize="22px"
          icon="undo"
          tooltip="Rotate"
          tooltipPosition="top"
        />
      </Stack.Item>

      <Stack.Item>
        <Button
          onClick={props.handleRotate}
          fontSize="22px"
          icon="redo"
          tooltip="Rotate"
          tooltipPosition="top"
        />
      </Stack.Item>

      <Stack.Item>
        <Button
          onClick={props.handleOpenSpecies}
          fontSize="22px"
          icon="paw"
          tooltip="Species"
          tooltipPosition="top"
        />
      </Stack.Item>

      {props.showGender && (
        <Stack.Item>
          <GenderButton
            gender={props.gender}
            handleSetGender={props.setGender}
          />
        </Stack.Item>
      )}
      {props.handleLoadout && (
        <Stack.Item>
          <Button
            onClick={props.handleLoadout}
            fontSize="22px"
            icon="suitcase"
            tooltip="Show Loadout Menu"
            tooltipPosition="top"
          />
        </Stack.Item>
      )}
    </Stack>
  );
};

const ChoicedSelection = (props: {
  name: string;
  catalog: FeatureChoicedServerData;
  selected: string;
  supplementalFeature?: string;
  supplementalValue?: unknown;
  onClose: () => void;
  onSelect: (value: string) => void;
  searchText: string;
  setSearchText: (value: string) => void;
}) => {
  const { act } = useBackend<PreferencesMenuData>();

  const {
    catalog,
    supplementalFeature,
    supplementalValue,
    searchText,
    setSearchText,
  } = props;

  if (!catalog.icons) {
    return <Box color="red">Provided catalog had no icons!</Box>;
  }

  let search = createSearch(searchText, (name: string) => {
    return name;
  });

  const entryCount = Object.keys(catalog.icons).length;

  const calculatedWidth =
    CLOTHING_SELECTION_CELL_SIZE_HORIZONTAL *
    Math.min(entryCount, ENTRIES_PER_ROW);
  const baseHeight =
    CLOTHING_SELECTION_CELL_SIZE_VERTICAL *
    Math.min(Math.ceil(entryCount / ENTRIES_PER_ROW), MAX_ROWS);
  const calculatedHeight = baseHeight;

  return (
    <Box
      style={{
        background: '#424651',
        padding: '5px',

        height: `${
          CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_MULTIPLIER
        }px`,
        width: `${CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_WIDTH}px`,
      }}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Stack fill>
            <Stack.Item ml={0.2} mt={0.5}>
              {supplementalFeature && (
                <FeatureValueInput
                  act={act}
                  feature={features[supplementalFeature]}
                  featureId={supplementalFeature}
                  shrink
                  value={supplementalValue}
                />
              )}
            </Stack.Item>
            <Stack.Item grow mr={6}>
              <Box
                style={{
                  fontWeight: 'bold',
                  fontSize: '18px',
                  color: '#e6e7eb',
                  textAlign: 'center',
                }}
              >
                {props.name}
              </Box>
            </Stack.Item>

            <Stack.Item>
              <Button
                style={{
                  fontWeight: 'bold',
                  fontSize: '14px',
                  textAlign: 'center',
                }}
                color="#424651"
                onClick={props.onClose}
              >
                {' '}
                x
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item textColor="#e6e7eb" verticalAlign="middle">
          <Box>
            <Icon ml={1} mr={1.5} name="search" />
            <Input
              autoFocus
              width={`83.5%`}
              placeholder=""
              value={searchText}
              onInput={(_, value) => setSearchText(value)}
            />
          </Box>
        </Stack.Item>
        <Stack.Item overflowX="hidden" overflowY="auto">
          <Autofocus>
            <Flex wrap>
              {Object.entries(catalog.icons)
                .filter(([n, _]) => searchText?.length < 1 || search(n))
                .map(([name, image], index) => {
                  return (
                    <Flex.Item
                      key={index}
                      basis={`${CLOTHING_SELECTION_CELL_SIZE}px`}
                      style={{
                        padding: '5px',
                      }}
                    >
                      <Button
                        onClick={() => {
                          props.onSelect(name);
                        }}
                        selected={name === props.selected}
                        tooltip={name}
                        tooltipPosition="right"
                        style={{
                          height: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                          width: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                        }}
                      >
                        <Box
                          className={classes([
                            'preferences32x32',
                            image,
                            'centered-image',
                          ])}
                          style={{
                            transform:
                              'translateX(-50%) translateY(-50%) scale(2)',
                          }}
                        />
                      </Button>
                      <Box
                        textAlign="center"
                        fontSize="14"
                        width="86%"
                        color="#e6e7eb"
                      >
                        {name}
                      </Box>
                    </Flex.Item>
                  );
                })}
            </Flex>
          </Autofocus>
        </Stack.Item>
        {supplementalFeature && (
          <>
            <Stack.Item mt={0.25}>
              <Box
                pb={0.25}
                style={{
                  borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
                  fontWeight: 'bold',
                  fontSize: '14px',
                  textAlign: 'center',
                }}
              >
                {features[supplementalFeature].name}
              </Box>
            </Stack.Item>
            <Stack.Item shrink mt={0.5}>
              <FeatureValueInput
                act={act}
                feature={features[supplementalFeature]}
                featureId={supplementalFeature}
                shrink
                value={supplementalValue}
              />
            </Stack.Item>
          </>
        )}
      </Stack>
    </Box>
  );
};

const GenderButton = (props: {
  handleSetGender: (gender: Gender) => void;
  gender: Gender;
}) => {
  const [genderMenuOpen, setGenderMenuOpen] = useState(false);

  return (
    <Popper
      isOpen={genderMenuOpen}
      onClickOutside={() => setGenderMenuOpen(false)}
      placement="right-end"
      content={
        <Stack backgroundColor="white" ml={0.5} p={0.3}>
          {[Gender.Male, Gender.Female, Gender.Other, Gender.Other2].map(
            (gender) => {
              return (
                <Stack.Item key={gender}>
                  <Button
                    selected={gender === props.gender}
                    onClick={() => {
                      props.handleSetGender(gender);
                      setGenderMenuOpen(false);
                    }}
                    fontSize="22px"
                    icon={GENDERS[gender].icon}
                    tooltip={GENDERS[gender].text}
                    tooltipPosition="top"
                  />
                </Stack.Item>
              );
            },
          )}
        </Stack>
      }
    >
      <Button
        onClick={() => {
          setGenderMenuOpen(!genderMenuOpen);
        }}
        fontSize="22px"
        icon={GENDERS[props.gender].icon}
        tooltip="Gender"
        tooltipPosition="top"
      />
    </Popper>
  );
};

const MainFeature = (props: {
  catalog: FeatureChoicedServerData & {
    name: string;
    supplemental_feature?: string;
  };
  currentValue: string;
  isOpen: boolean;
  handleClose: () => void;
  handleOpen: () => void;
  handleSelect: (newClothing: string) => void;
  randomization?: RandomSetting;
  setRandomization: (newSetting: RandomSetting) => void;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();

  const {
    catalog,
    currentValue,
    isOpen,
    handleOpen,
    handleClose,
    handleSelect,
    randomization,
    setRandomization,
  } = props;

  const supplementalFeature = catalog.supplemental_feature;
  let [searchText, setSearchText] = useState('');
  const handleCloseInternal = () => {
    handleClose();
    setSearchText('');
  };

  return (
    <Popper
      placement="bottom-start"
      onClickOutside={handleClose}
      isOpen={isOpen}
      content={
        <ChoicedSelection
          name={catalog.name}
          catalog={catalog}
          selected={currentValue}
          supplementalFeature={supplementalFeature}
          supplementalValue={
            supplementalFeature &&
            data.character_preferences.supplemental_features[
              supplementalFeature
            ]
          }
          onClose={handleClose}
          onSelect={handleSelect}
          searchText={searchText}
          setSearchText={setSearchText}
        />
      }
    >
      <Button
        mt="-3px"
        onClick={(event) => {
          event.stopPropagation();
          if (isOpen) {
            handleClose();
          } else {
            handleOpen();
          }
        }}
        style={{
          height: `${CLOTHING_CELL_SIZE}px`,
          width: `${CLOTHING_CELL_SIZE}px`,
        }}
        color="blue"
        position="relative"
        tooltip={catalog.name}
        tooltipPosition="right"
      >
        <Box
          className={classes([
            'preferences32x32',
            catalog.icons![currentValue],
            'centered-image',
          ])}
          style={{
            transform: randomization
              ? 'translateX(-70%) translateY(-70%) scale(2)'
              : 'translateX(-50%) translateY(-50%) scale(2)',
          }}
        />

        {randomization && (
          <RandomizationButton
            dropdownProps={{
              dropdownStyle: {
                bottom: 0,
                position: 'absolute',
                right: '1px',
              },

              onOpen: (event) => {
                // We're a button inside a button.
                // Did you know that's against the W3C standard? :)
                event.cancelBubble = true;
                event.stopPropagation();
              },
            }}
            value={randomization}
            setValue={setRandomization}
          />
        )}
      </Button>
      <Box
        mt={-0.5}
        mb={1.1}
        style={{
          // Text below feature buttons
          height: `14px`,
          width: `${CLOTHING_CELL_SIZE}px`,
          overflowWrap: 'anywhere',
        }}
        textAlign="center"
        textColor="#e6e7eb"
      >
        {catalog.name}
      </Box>
    </Popper>
  );
};

const createSetRandomization =
  (act: typeof sendAct, preference: string) => (newSetting: RandomSetting) => {
    act('set_random_preference', {
      preference,
      value: newSetting,
    });
  };

const sortPreferences = (array: [string, unknown][]) =>
  sortBy(array, ([featureId, _]) => {
    const feature = features[featureId];
    return feature?.name;
  });

export const PreferenceList = (props: {
  act: typeof sendAct;
  preferences: Record<string, unknown>;
  randomizations: Record<string, RandomSetting>;
  maxHeight: string;
}) => {
  return (
    <Stack.Item
      basis="50%"
      grow
      style={{
        padding: '2px',
      }}
      overflowX="hidden"
      overflowY="auto"
      ml="-6px"
      maxHeight={props.maxHeight}
    >
      <LabeledList>
        {sortPreferences(Object.entries(props.preferences)).map(
          ([featureId, value]) => {
            const feature = features[featureId];
            const randomSetting = props.randomizations[featureId];

            if (feature === undefined) {
              return (
                <Stack.Item key={featureId}>
                  <b>Feature {featureId} is not recognized.</b>
                </Stack.Item>
              );
            }

            return (
              <LabeledList.Item
                key={featureId}
                // label={feature.name}
                label={<Box width="144px">{feature.name}</Box>}
                verticalAlign="middle"
              >
                <Stack fill mr={1}>
                  {randomSetting && (
                    <Stack.Item>
                      <RandomizationButton
                        setValue={createSetRandomization(props.act, featureId)}
                        value={randomSetting}
                      />
                    </Stack.Item>
                  )}

                  <Stack.Item grow>
                    <FeatureValueInput
                      act={props.act}
                      feature={feature}
                      featureId={featureId}
                      value={value}
                    />
                  </Stack.Item>
                </Stack>
              </LabeledList.Item>
            );
          },
        )}
      </LabeledList>
    </Stack.Item>
  );
};

export const getRandomization = (
  preferences: Record<string, unknown>,
  serverData: ServerData | undefined,
  randomBodyEnabled: boolean,
): Record<string, RandomSetting> => {
  if (!serverData) {
    return {};
  }

  const { data } = useBackend<PreferencesMenuData>();

  if (!randomBodyEnabled) {
    return {};
  }

  return Object.fromEntries(
    map(
      filter(Object.keys(preferences), (key) =>
        serverData.random.randomizable.includes(key),
      ),
      (key) => [
        key,
        data.character_preferences.randomization[key] || RandomSetting.Disabled,
      ],
    ),
  );
};

export const MainPage = (props: { openSpecies: () => void }) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const [currentClothingMenu, setCurrentClothingMenu] = useState<string | null>(
    null,
  );
  const [multiNameInputOpen, setMultiNameInputOpen] = useState(false);
  const [randomToggleEnabled] = useRandomToggleState();

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        const currentSpeciesData =
          serverData &&
          serverData.species[data.character_preferences.misc.species];

        const contextualPreferences =
          data.character_preferences.secondary_features || [];

        const mainFeatures = [
          ...Object.entries(data.character_preferences.clothing),
          ...Object.entries(data.character_preferences.features).filter(
            ([featureName]) => {
              if (!currentSpeciesData) {
                return false;
              }

              return (
                currentSpeciesData.enabled_features.indexOf(featureName) !== -1
              );
            },
          ),
        ];

        const randomBodyEnabled =
          data.character_preferences.non_contextual.random_body !==
            RandomSetting.Disabled || randomToggleEnabled;

        const randomizationOfMainFeatures = getRandomization(
          Object.fromEntries(mainFeatures),
          serverData,
          randomBodyEnabled,
        );

        const nonContextualPreferences = {
          ...data.character_preferences.non_contextual,
        };

        if (randomBodyEnabled) {
          nonContextualPreferences['random_species'] =
            data.character_preferences.randomization['species'];
        } else {
          // We can't use random_name/is_accessible because the
          // server doesn't know whether the random toggle is on.
          delete nonContextualPreferences['random_name'];
        }

        return (
          <>
            {multiNameInputOpen && (
              <MultiNameInput
                handleClose={() => setMultiNameInputOpen(false)}
                handleRandomizeName={(preference) =>
                  act('randomize_name', {
                    preference,
                  })
                }
                handleUpdateName={(nameType, value) =>
                  act('set_preference', {
                    preference: nameType,
                    value,
                  })
                }
                names={data.character_preferences.names}
              />
            )}

            <Stack height={`${CLOTHING_SIDEBAR_ROWS * CLOTHING_CELL_SIZE}px`}>
              <Stack.Item>
                <Stack vertical fill>
                  <Stack.Item>
                    <CharacterControls
                      gender={data.character_preferences.misc.gender}
                      handleOpenSpecies={props.openSpecies}
                      handleRotate={() => {
                        act('rotate');
                      }}
                      handleLoadout={() => {
                        act('open_loadout');
                      }}
                      setGender={createSetPreference(act, 'gender')}
                      showGender={
                        currentSpeciesData ? !!currentSpeciesData.sexes : true
                      }
                    />
                  </Stack.Item>

                  <Stack.Item grow>
                    <CharacterPreview
                      height="92%"
                      id={data.character_preview_view}
                    />
                  </Stack.Item>

                  <Stack.Item
                    // Preview Mode
                    position="relative"
                    mt="-40px"
                  />

                  <Stack.Item position="relative">
                    <NameInput
                      name={data.character_preferences.names[data.name_to_use]}
                      handleUpdateName={createSetPreference(
                        act,
                        data.name_to_use,
                      )}
                      openMultiNameInput={() => {
                        setMultiNameInputOpen(true);
                      }}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>

              <Stack.Item width={`${CLOTHING_CELL_SIZE * 2.1}px`}>
                <Stack height="100%" vertical wrap>
                  {mainFeatures.map(([clothingKey, clothing]) => {
                    const catalog =
                      serverData &&
                      (serverData[clothingKey] as FeatureChoicedServerData & {
                        name: string;
                      });

                    return (
                      catalog && (
                        <Stack.Item
                          key={clothingKey}
                          mt={0.5}
                          mr={1.6}
                          px={0.5}
                        >
                          <MainFeature
                            catalog={catalog}
                            currentValue={clothing}
                            isOpen={currentClothingMenu === clothingKey}
                            handleClose={() => {
                              setCurrentClothingMenu(null);
                            }}
                            handleOpen={() => {
                              setCurrentClothingMenu(clothingKey);
                            }}
                            handleSelect={createSetPreference(act, clothingKey)}
                            randomization={
                              randomizationOfMainFeatures[clothingKey]
                            }
                            setRandomization={createSetRandomization(
                              act,
                              clothingKey,
                            )}
                          />
                        </Stack.Item>
                      )
                    );
                  })}
                </Stack>
              </Stack.Item>

              <Stack.Item grow basis={0}>
                <Stack vertical fill>
                  <PreferenceList
                    act={act}
                    randomizations={getRandomization(
                      contextualPreferences,
                      serverData,
                      randomBodyEnabled,
                    )}
                    preferences={contextualPreferences}
                    maxHeight="270px"
                  />

                  <PreferenceList
                    act={act}
                    randomizations={getRandomization(
                      nonContextualPreferences,
                      serverData,
                      randomBodyEnabled,
                    )}
                    preferences={nonContextualPreferences}
                    maxHeight="auto"
                  />
                </Stack>
              </Stack.Item>
            </Stack>
          </>
        );
      }}
    />
  );
};

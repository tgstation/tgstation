import { sortBy } from 'es-toolkit';
import { filter, map } from 'es-toolkit/compat';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { sendAct } from 'tgui/events/act';
import {
  Box,
  Button,
  Floating,
  Icon,
  ImageButton,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalize, createSearch } from 'tgui-core/string';
import { CharacterPreview } from '../../common/CharacterPreview';
import { Preference } from '../components/Preference';
import { RandomizationButton } from '../components/RandomizationButton';
import { BodyModificationsPage } from '../preferences/BodyModificationsPage';
import { features } from '../preferences/features';
import {
  type FeatureChoicedServerData,
  FeatureValueInput,
} from '../preferences/features/base';
import { GENDERS, Gender } from '../preferences/gender';
import {
  createSetPreference,
  type PreferencesMenuData,
  RandomSetting,
  type ServerData,
} from '../types';
import { useRandomToggleState } from '../useRandomToggleState';
import { useServerPrefs } from '../useServerPrefs';
import { DeleteCharacterPopup } from './DeleteCharacterPopup';
import { AlternativeNames, NameInput } from './names';

type CharacterControlsProps = {
  handleRotate: () => void;
  handleOpenSpecies: () => void;
  handleOpenAugmentations: () => void; // BANDASTATION ADD: Augmentations
  gender: Gender;
  setGender: (gender: Gender) => void;
  showGender: boolean;
  canDeleteCharacter: boolean;
  handleDeleteCharacter: () => void;
};

function CharacterControls(props: CharacterControlsProps) {
  return (
    <Stack className="PreferencesMenu__CharacterControls">
      <Button
        icon="undo"
        tooltip="Повернуть"
        tooltipPosition="top"
        onClick={props.handleRotate}
      />
      <Button
        icon="paw"
        tooltip="Вид"
        tooltipPosition="top"
        onClick={props.handleOpenSpecies}
      />
      {props.showGender && (
        <GenderButton gender={props.gender} handleSetGender={props.setGender} />
      )}
      <Button
        icon="robot"
        tooltip="Модификации тела"
        tooltipPosition="top"
        onClick={() => props.handleOpenAugmentations()}
      />
      <Button
        color="red"
        icon="trash"
        tooltip="Удалить персонажа"
        tooltipPosition="top"
        disabled={!props.canDeleteCharacter}
        onClick={props.handleDeleteCharacter}
      />
    </Stack>
  );
}

type GenderButtonProps = {
  handleSetGender: (gender: Gender) => void;
  gender: Gender;
};

function GenderButton(props: GenderButtonProps) {
  return (
    <Floating
      placement="top"
      content={
        <Stack className="PreferencesMenu__CharacterControls Gender">
          <Section>
            {Object.values(Gender).map((gender) => {
              return (
                <Button
                  key={gender}
                  selected={gender === props.gender}
                  icon={GENDERS[gender]?.icon || 'question'}
                  tooltip={GENDERS[gender]?.text || 'Кто ты, воин?'}
                  tooltipPosition="top"
                  onClick={() => {
                    props.handleSetGender(gender);
                  }}
                />
              );
            })}
          </Section>
        </Stack>
      }
    >
      <div>
        <Button
          icon={GENDERS[props.gender]?.icon || 'question'}
          tooltip="Пол"
          tooltipPosition="top"
        />
      </div>
    </Floating>
  );
}

type ChoicedSelectionProps = {
  name: string;
  catalog: FeatureChoicedServerData;
  selected: string;
  supplementalFeature?: string;
  supplementalValue?: unknown;
  onSelect: (value: string) => void;
};

function ChoicedSelection(props: ChoicedSelectionProps) {
  const { catalog, supplementalFeature, supplementalValue } = props;
  const [searchText, setSearchText] = useState('');

  if (!catalog.icons) {
    return <Box color="red">В предоставленном каталоге не было иконок!</Box>;
  }

  return (
    <Stack fill vertical g={0} className="PreferencesMenu__ChoicedSelection">
      <Stack.Item>
        <Section
          fill
          title={`${capitalize(props.name)}`}
          buttons={
            supplementalFeature && (
              <FeatureValueInput
                shrink
                feature={features[supplementalFeature]}
                featureId={supplementalFeature}
                value={supplementalValue}
              />
            )
          }
        >
          <Input
            autoFocus
            fluid
            placeholder="Поиск..."
            onChange={setSearchText}
          />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable noTopPadding>
          <Stack wrap>
            {searchInCatalog(searchText, catalog.icons).map(
              ([name, image], index) => {
                return (
                  <ImageButton
                    key={index}
                    asset={['preferences32x32', image]}
                    imageSize={32}
                    selected={name === props.selected}
                    tooltip={name}
                    tooltipPosition="right"
                    onClick={() => {
                      props.onSelect(name);
                    }}
                  />
                );
              },
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function searchInCatalog(searchText = '', catalog: Record<string, string>) {
  let items = Object.entries(catalog);
  if (searchText) {
    items = filter(
      items,
      createSearch(searchText, ([name, _icon]) => name),
    );
  }
  return items;
}

type CatalogItem = {
  name: string;
  supplemental_feature?: string;
};

type MainFeatureProps = {
  catalog: FeatureChoicedServerData & CatalogItem;
  currentValue: string;
  handleSelect: (newClothing: string) => void;
  randomization?: RandomSetting;
  setRandomization: (newSetting: RandomSetting) => void;
};

function MainFeature(props: MainFeatureProps) {
  const { data } = useBackend<PreferencesMenuData>();
  const {
    catalog,
    currentValue,
    handleSelect,
    randomization,
    setRandomization,
  } = props;

  const supplementalFeature = catalog.supplemental_feature;
  return (
    <Floating
      stopChildPropagation
      placement="right-start"
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
          onSelect={handleSelect}
        />
      }
    >
      <ImageButton
        className="PreferencesMenu__MainFeature"
        asset={['preferences32x32', catalog.icons![currentValue]]}
        imageSize={48}
        buttons={
          randomization && (
            <RandomizationButton
              value={randomization}
              setValue={setRandomization}
            />
          )
        }
      />
    </Floating>
  );
}

const createSetRandomization =
  (preference: string) => (newSetting: RandomSetting) => {
    sendAct('set_random_preference', {
      preference,
      value: newSetting,
    });
  };

function sortPreferences(array: [string, unknown][]) {
  return sortBy(array, [([featureId]) => features[featureId]?.name]);
}

type PreferenceListProps = {
  preferences: Record<string, unknown>;
  randomizations: Record<string, RandomSetting>;
};

export function PreferenceList(props: PreferenceListProps) {
  const { act } = useBackend<PreferencesMenuData>();
  const { preferences, randomizations } = props;

  return Object.entries(preferences).length > 0 ? (
    <Stack vertical>
      {sortPreferences(Object.entries(preferences)).map(
        ([featureId, value]) => {
          const feature = features[featureId];
          const randomSetting = randomizations[featureId];
          if (feature === undefined) {
            return (
              <Stack.Item key={featureId} bold>
                Компонент {featureId} не распознан.
              </Stack.Item>
            );
          }

          return (
            <Preference
              key={featureId}
              id={featureId}
              name={feature.name}
              description={feature.description}
              childrenClassName="Character"
            >
              <FeatureValueInput
                value={value}
                feature={feature}
                featureId={featureId}
              />
              {randomSetting && (
                <RandomizationButton
                  setValue={createSetRandomization(featureId)}
                  value={randomSetting}
                />
              )}
            </Preference>
          );
        },
      )}
    </Stack>
  ) : (
    <Stack fill vertical align="center" justify="center" my="auto" g={3}>
      <Stack.Item>
        <Icon name="face-sad-cry" size={7.5} color="blue" />
      </Stack.Item>
      <Stack.Item bold fontSize={1.25} color="label" textAlign="center">
        К сожалению, выбранная раса не имеет дополнительных параметров
        внешности.
      </Stack.Item>
    </Stack>
  );
}

export function getRandomization(
  preferences: Record<string, unknown>,
  serverData: ServerData | undefined,
  randomBodyEnabled: boolean,
): Record<string, RandomSetting> {
  const { data } = useBackend<PreferencesMenuData>();
  if (!randomBodyEnabled || !serverData) {
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
}

type MainPageProps = {
  openSpecies: () => void;
};

export function MainPage(props: MainPageProps) {
  const { act, data } = useBackend<PreferencesMenuData>();

  const [deleteCharacterPopupOpen, setDeleteCharacterPopupOpen] =
    useState(false);
  const [randomToggleEnabled] = useRandomToggleState();
  const [augmentationInputOpen, setAugmentationInputOpen] = useState(false);

  const serverData = useServerPrefs();

  const currentSpeciesData =
    serverData?.species[data.character_preferences.misc.species];

  const contextualPreferences =
    data.character_preferences.secondary_features || [];

  const mainFeatures = [
    ...Object.entries(data.character_preferences.clothing ?? {}),
    ...Object.entries(data.character_preferences.features ?? {}),
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
    nonContextualPreferences.random_species =
      data.character_preferences.randomization.species;
    // BANDASTATION ADDITION START - TTS
    nonContextualPreferences.random_tts_seed =
      data.character_preferences.randomization.tts_seed;
    // BANDASTATION ADDITION END - TTS
  } else {
    // We can't use random_name/is_accessible because the
    // server doesn't know whether the random toggle is on.
    delete nonContextualPreferences.random_name;
  }

  const Character = (
    <Section fill className="PreferencesMenu__Character">
      <Stack fill vertical>
        <Stack.Item>
          <CharacterControls
            gender={data.character_preferences.misc.gender}
            handleOpenSpecies={props.openSpecies}
            handleOpenAugmentations={() => setAugmentationInputOpen(true)} // BANDASTATION ADDITION - Feat: Augmentations
            handleRotate={() => {
              act('rotate');
            }}
            setGender={createSetPreference(act, 'gender')}
            showGender={currentSpeciesData ? !!currentSpeciesData.sexes : true}
            canDeleteCharacter={
              Object.values(data.character_profiles).filter((name) => !!name)
                .length > 1
            }
            handleDeleteCharacter={() => setDeleteCharacterPopupOpen(true)}
          />
        </Stack.Item>
        <Stack.Item grow style={{ alignSelf: 'center' }}>
          <CharacterPreview height="100%" id={data.character_preview_view} />
        </Stack.Item>
        <Stack.Item>
          <NameInput
            large
            canRandomize
            name={data.character_preferences.names[data.name_to_use]}
            nameType={data.name_to_use}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );

  const MainFeatures = (
    <Section fill scrollable pl={0.7} width={6.5} ml={-1}>
      <Stack vertical direction="column-reverse">
        {mainFeatures.map(([clothingKey, clothing]) => {
          const catalog = serverData?.[
            clothingKey
          ] as FeatureChoicedServerData & {
            name: string;
          };

          return (
            <Stack.Item key={clothingKey}>
              {!catalog ? (
                <ImageButton imageSize={48} />
              ) : (
                <MainFeature
                  catalog={catalog}
                  currentValue={clothing}
                  handleSelect={createSetPreference(act, clothingKey)}
                  randomization={randomizationOfMainFeatures[clothingKey]}
                  setRandomization={createSetRandomization(clothingKey)}
                />
              )}
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );

  return (
    <Stack fill>
      {augmentationInputOpen && (
        <BodyModificationsPage
          handleClose={() => setAugmentationInputOpen(false)}
        />
      )}

      {deleteCharacterPopupOpen && (
        <DeleteCharacterPopup
          close={() => setDeleteCharacterPopupOpen(false)}
        />
      )}
      <Stack.Item>
        <Stack fill vertical>
          <Stack.Item basis="50%">{Character}</Stack.Item>
          <Stack.Item grow mr={1}>
            <AlternativeNames names={data.character_preferences.names} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>{MainFeatures}</Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item basis="37.5%">
            <Section fill scrollable>
              <PreferenceList
                preferences={contextualPreferences}
                randomizations={getRandomization(
                  contextualPreferences,
                  serverData,
                  randomBodyEnabled,
                )}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <PreferenceList
                preferences={nonContextualPreferences}
                randomizations={getRandomization(
                  nonContextualPreferences,
                  serverData,
                  randomBodyEnabled,
                )}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

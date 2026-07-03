import { useEffect, useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  BlockQuote,
  Button,
  Dropdown,
  Icon,
  LabeledList,
  Section,
  Stack,
  Tooltip,
  VirtualList,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { LoadingScreen } from '../../common/LoadingScreen';
import { SearchBar } from '../../common/SearchBar';
import type { PreferencesMenuData, Seed, TtsData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

const donatorTiers = {
  0: 'Free',
  1: 'Tier I',
  2: 'Tier II',
  3: 'Tier III',
  4: 'Tier IV',
  5: 'Tier V',
};

const gendersIcons = {
  Мужской: {
    icon: 'mars',
    color: 'blue',
  },
  Женский: {
    icon: 'venus',
    color: 'purple',
  },
  Любой: {
    icon: 'venus-mars',
    color: 'white',
  },
};

const getCheckboxGroup = (
  itemsList,
  selectedList,
  setSelected,
  contentKey: string | null = null,
) => {
  return itemsList.map((item) => {
    const title = (contentKey && item[contentKey]) ?? item;
    return (
      <Button.Checkbox
        key={title}
        checked={selectedList.includes(item)}
        onClick={() => {
          if (selectedList.includes(item)) {
            setSelected(
              selectedList.filter(
                (i) => ((contentKey && i[contentKey]) ?? i) !== item,
              ),
            );
          } else {
            setSelected([item, ...selectedList]);
          }
        }}
      >
        {title}
      </Button.Checkbox>
    );
  });
};

export const VoicePage = () => {
  const serverData = useServerPrefs();
  if (!serverData) {
    return <LoadingScreen />;
  }

  return <VoicePageInner text_to_speech={serverData.text_to_speech} />;
};

const VoicePageInner = (props: { text_to_speech: TtsData }) => {
  const { data } = useBackend<PreferencesMenuData>();
  const { tts_seed } = data;
  const { providers, seeds, phrases } = props.text_to_speech;

  const donator_level = 5; // Remove after tiers implementation

  const categories = seeds
    .map((seed) => seed.category)
    .filter((category, i, a) => a.indexOf(category) === i);

  const genders = seeds
    .map((seed) => seed.gender)
    .filter((gender, i, a) => a.indexOf(gender) === i);

  const donatorLevels = seeds
    .map((seed) => seed.donator_level)
    .filter((level, i, a) => a.indexOf(level) === i)
    .sort((a, b) => a - b)
    .map((level) => donatorTiers[level]);

  const [selectedProviders, setSelectedProviders] = useState(providers);
  const [selectedGenders, setSelectedGenders] = useState(genders);
  const [selectedCategories, setSelectedCategories] = useState(categories);
  const [selectedDonatorLevels, setSelectedDonatorLevels] =
    useState(donatorLevels);
  const [selectedPhrase, setSelectedPhrase] = useState(phrases[0]);
  const [searchtext, setSearchtext] = useState('');
  const [selectedSeed, setSelectedSeed] = useState<Seed>();

  const providerCheckboxes = getCheckboxGroup(
    providers,
    selectedProviders,
    setSelectedProviders,
    'name',
  );
  const genderesCheckboxes = getCheckboxGroup(
    genders,
    selectedGenders,
    setSelectedGenders,
  );
  const categoriesCheckboxes = getCheckboxGroup(
    categories,
    selectedCategories,
    setSelectedCategories,
  );
  const donatorLevelsCheckboxes = getCheckboxGroup(
    donatorLevels,
    selectedDonatorLevels,
    setSelectedDonatorLevels,
  );

  const phrasesSelect = (
    <Dropdown
      options={phrases}
      selected={selectedPhrase.replace(/(.{60})..+/, '$1...')}
      onSelected={(value) => setSelectedPhrase(value)}
    />
  );

  const searchBar = (
    <SearchBar
      placeholder="Название..."
      query={searchtext}
      onSearch={setSearchtext}
    />
  );

  const availableSeeds = seeds
    .sort((a, b) => {
      const aname = a.name.toLowerCase();
      const bname = b.name.toLowerCase();
      if (aname > bname) {
        return 1;
      }
      if (aname < bname) {
        return -1;
      }
      return 0;
    })
    .filter(
      (seed) =>
        selectedProviders.some((provider) => provider.name === seed.provider) &&
        selectedGenders.includes(seed.gender) &&
        selectedCategories.includes(seed.category) &&
        selectedDonatorLevels.includes(donatorTiers[seed.donator_level]) &&
        seed.name.toLowerCase().includes(searchtext.toLowerCase()),
    );

  useEffect(() => {
    const selected = availableSeeds.find((seed) => seed.name === tts_seed);
    setSelectedSeed(selected);
  }, [tts_seed]);

  return (
    <Stack fill>
      <Stack.Item basis={'40%'}>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Фильтры">
              <LabeledList>
                <LabeledList.Item label="Провайдеры">
                  {providerCheckboxes}
                </LabeledList.Item>
                <LabeledList.Item label="Пол">
                  {genderesCheckboxes}
                </LabeledList.Item>
                <LabeledList.Item label="Тир">
                  {donatorLevelsCheckboxes}
                </LabeledList.Item>
                <LabeledList.Item label="Фраза">
                  {phrasesSelect}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Категории"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="bad"
                      disabled={selectedCategories.length === 0}
                      onClick={() => setSelectedCategories([])}
                    >
                      Убрать всё
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="check"
                      color="good"
                      disabled={selectedCategories.length === categories.length}
                      onClick={() => setSelectedCategories(categories)}
                    >
                      Выбрать всё
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            >
              {categoriesCheckboxes}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <BlockQuote>
                <Stack.Item>
                  Для поддержания и развития сообщества в условиях растущих
                  расходов часть голосов пришлось сделать доступными только за
                  материальную поддержку сообщества.
                </Stack.Item>
                <Stack.Item mt={1} italic fontSize={0.9} opacity={0.75}>
                  Подробнее об этом можно узнать в нашем Discord-сообществе.
                </Stack.Item>
              </BlockQuote>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical>
          <Section
            fill
            scrollable
            title={`Голоса (${availableSeeds.length}/${seeds.length})`}
            buttons={searchBar}
          >
            <Stack vertical>
              {selectedSeed && (
                <SeedRow
                  header
                  seed={selectedSeed}
                  selected_seed={tts_seed}
                  selected_phrase={selectedPhrase}
                  donator_level={donator_level}
                />
              )}
              <VirtualList>
                {availableSeeds.map((seed) => {
                  return (
                    <SeedRow
                      key={seed.name}
                      seed={seed}
                      selected_seed={tts_seed}
                      selected_phrase={selectedPhrase}
                      donator_level={donator_level}
                    />
                  );
                })}
              </VirtualList>
            </Stack>
          </Section>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const SeedRow = (props: {
  seed: Seed;
  selected_seed: string;
  selected_phrase: string;
  donator_level: number;
  header?: boolean;
}) => {
  const { seed, selected_seed, selected_phrase, donator_level, header } = props;
  const { act } = useBackend();
  const seedSelected = selected_seed === seed.name;
  return (
    <Tooltip
      content={
        donator_level < seed.donator_level &&
        'Требуется более высокий уровень подписки'
      }
    >
      <Stack
        fill
        className={classes([
          'PreferencesMenu__Voice',
          seedSelected && 'selected',
          header && 'header',
        ])}
        onClick={() =>
          !seedSelected && act('select_voice', { seed: seed.name })
        }
      >
        <Stack.Item>
          <Button
            fluid
            icon="music"
            color={seedSelected ? 'green' : 'transparent'}
            tooltip="Прослушать пример"
            onClick={(e) => {
              e.stopPropagation();
              act('listen', { seed: seed.name, phrase: selected_phrase });
            }}
          />
        </Stack.Item>
        <Stack.Item
          bold
          grow
          textColor={
            seed.donator_level > 0 && selected_seed !== seed.name
              ? 'orange'
              : 'white'
          }
        >
          {seed.name}
        </Stack.Item>
        <Stack.Item
          className="PreferencesMenu__Voice--Category"
          opacity={seedSelected ? 0.75 : 0.25}
        >
          {seed.category}
        </Stack.Item>
        <Stack.Item className="PreferencesMenu__Voice--Tier">
          {seed.donator_level > 0 && (
            <>
              {donatorTiers[seed.donator_level]}
              <Icon ml={1} size={1.2} name="coins" />
            </>
          )}
        </Stack.Item>
        <Stack.Item
          className="PreferencesMenu__Voice--GenderIcon"
          textColor={seedSelected ? 'white' : gendersIcons[seed.gender].color}
        >
          <Icon size={1.2} name={gendersIcons[seed.gender].icon} />
        </Stack.Item>
      </Stack>
    </Tooltip>
  );
};

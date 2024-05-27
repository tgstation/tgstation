import { useState } from 'react';

import { useBackend } from '../../backend';
import {
  BlockQuote,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
  VirtualList,
} from '../../components';
import { PreferencesMenuData, Seed } from './data';

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
        content={title}
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
      />
    );
  });
};

export const VoicePage = (props) => {
  const { data } = useBackend<PreferencesMenuData>();

  const {
    providers,
    seeds,
    tts_seed,
    phrases,
    // donator_level,
    // character_gender,
  } = data;

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

  let providerCheckboxes = getCheckboxGroup(
    providers,
    selectedProviders,
    setSelectedProviders,
    'name',
  );
  let genderesCheckboxes = getCheckboxGroup(
    genders,
    selectedGenders,
    setSelectedGenders,
  );
  let categoriesCheckboxes = getCheckboxGroup(
    categories,
    selectedCategories,
    setSelectedCategories,
  );
  let donatorLevelsCheckboxes = getCheckboxGroup(
    donatorLevels,
    selectedDonatorLevels,
    setSelectedDonatorLevels,
  );

  let phrasesSelect = (
    <Dropdown
      options={phrases}
      selected={selectedPhrase.replace(/(.{60})..+/, '$1...')}
      onSelected={(value) => setSelectedPhrase(value)}
    />
  );

  let searchBar = (
    <Input
      placeholder="Название..."
      width="100%"
      onInput={(e, value) => setSearchtext(value)}
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
                <LabeledList.Item label="Поиск">{searchBar}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Категории"
              buttons={
                <>
                  <Button
                    icon="times"
                    disabled={selectedCategories.length === 0}
                    onClick={() => setSelectedCategories([])}
                  >
                    Убрать всё
                  </Button>
                  <Button
                    icon="check"
                    disabled={selectedCategories.length === categories.length}
                    onClick={() => setSelectedCategories(categories)}
                  >
                    Выбрать всё
                  </Button>
                </>
              }
            >
              {categoriesCheckboxes}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <BlockQuote>
                <Stack.Item>
                  {`Для поддержания и развития сообщества в условиях растущих расходов часть голосов пришлось сделать доступными только за материальную поддержку сообщества.`}
                </Stack.Item>
                <Stack.Item mt={1} italic>
                  {`Подробнее об этом можно узнать в нашем Discord-сообществе.`}
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
          >
            <Table>
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
            </Table>
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
}) => {
  const { seed, selected_seed, selected_phrase, donator_level } = props;
  const { act } = useBackend();
  return (
    <Table.Row
      backgroundColor={selected_seed === seed.name ? 'green' : 'transparent'}
    >
      <Table.Cell collapsing textAlign="center">
        <Button
          fluid
          color={selected_seed === seed.name ? 'green' : 'transparent'}
          tooltip={
            donator_level < seed.donator_level &&
            'Требуется более высокий уровень подписки'
          }
          onClick={() => act('select_voice', { seed: seed.name })}
        >
          {selected_seed === seed.name ? 'Выбрано' : 'Выбрать'}
        </Button>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          fluid
          icon="music"
          color={selected_seed === seed.name ? 'green' : 'transparent'}
          tooltip="Прослушать пример"
          onClick={() =>
            act('listen', { seed: seed.name, phrase: selected_phrase })
          }
        />
      </Table.Cell>
      <Table.Cell
        bold
        collapsing
        textColor={
          seed.donator_level > 0 && selected_seed !== seed.name
            ? 'orange'
            : 'white'
        }
      >
        {seed.name}
      </Table.Cell>
      <Table.Cell
        opacity={selected_seed === seed.name ? 0.5 : 0.25}
        textAlign="left"
      >
        {seed.category}
      </Table.Cell>
      <Table.Cell
        collapsing
        opacity={0.5}
        textColor={
          selected_seed === seed.name
            ? 'white'
            : gendersIcons[seed.gender].color
        }
        textAlign="left"
      >
        <Icon mx={1} size={1.2} name={gendersIcons[seed.gender].icon} />
      </Table.Cell>
      <Table.Cell collapsing opacity={0.5} textColor="white" textAlign="right">
        {seed.donator_level > 0 && (
          <>
            {donatorTiers[seed.donator_level]}
            <Icon ml={1} mr={2} name="coins" />
          </>
        )}
      </Table.Cell>
    </Table.Row>
  );
};

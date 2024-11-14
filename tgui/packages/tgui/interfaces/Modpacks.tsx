// THIS IS A MASSMETA UI FILE

import { useState } from 'react';
import {
  Box,
  Collapsible,
  Icon,
  Image,
  Input,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  categories: string[];
  features: Modpack[];
  perevody: Modpack[];
  reverts: Modpack[];
};

type Modpack = {
  id: string;
  name: string;
  desc: string;
  author: string;
};

export const Modpacks = (props) => {
  const { data } = useBackend<Data>();
  const { categories } = data;
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  return (
    <Window title="Список модификаций" width={480} height={580}>
      <NoticeBox>
        В данный момент идёт наполнение меню модпаков, в игре модицикаций больше
        чем вы можете тут видеть.
      </NoticeBox>
      <Window.Content scrollable>
        {modpacks.length === 0 ? (
          <NoticeBox>Этот сервер не использует какие-либо модификации</NoticeBox>
        ) : (
          <Tabs>
            <Tabs.Tab
              key={category}
              selected={selectedCategory === 'Features'}
              onClick={() => setSelectedCategory('Features')}
            >
              Фичи и Приколы
            </Tabs.Tab>
            <Tabs.Tab
              key={category}
              selected={selectedCategory === 'Perevody'}
              onClick={() => setSelectedCategory('Perevody')}
            >
              Переводы на Русский
            </Tabs.Tab>
            <Tabs.Tab
              key={category}
              selected={selectedCategory === 'Reverts'}
              onClick={() => setSelectedCategory('Reverts')}
            >
              Балансы и Реверты
            </Tabs.Tab>
          </Tabs>
          {(selectedCategory === 'Features' && <FeaturesTable />) ||
            (selectedCategory === 'Perevody' && <PerevodyTable />) ||
            (selectedCategory === 'Reverts' && <RevertsTable />)
            )}
        )}
	  </Window.Content>
    </Window>
  );
};

const FeaturesTable = () => {
  const { data } = useBackend<Data>();
  const { features } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');

  const searchBar = (
    <Input
      placeholder="Искать модпак..."
      fluid
      onInput={(e, value) => setSearchText(value)}
    />
  );

  return (
    <>
      <Stack.Item>
        <Section fill>{searchBar}</Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={
            searchText.length > 0 ? (
              <span>Результаты поиска "{searchText}":</span>
            ) : (
              <span>Суммарно модификации &mdash; {features.length}</span>
            )
          }
        >
          <Stack fill vertical>
            <Stack.Item>
              {features
                .filter(
                  (feature) =>
                    feature.name &&
                    (searchText.length > 0
                      ? feature.name
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        feature.desc
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        feature.author
                          .toLowerCase()
                          .includes(searchText.toLowerCase())
                      : true),
                )
                .map((feature) => (
                  <Collapsible
                    color="transparent"
                    key={feature.name}
                    title={<span class="color-white">{feature.name}</span>}
                  >
                    <Box
                      key={feature.id}
                      style={{
                        borderBottom: '1px solid #888',
                        paddingBottom: '10px',
                        fontSize: '14px',
                        textAlign: 'center',
                      }}
                    >
                      <ModpackItem key={feature.id} feature={feature} />
                    </Box>
                  </Collapsible>
                ))}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </>
  );
};

const ModpackItem = ({ modpack }) => (
  <>
    <LabeledList.Item label="Описание">{modpack.desc}</LabeledList.Item>
    <LabeledList.Item label="Автор">{modpack.author}</LabeledList.Item>
  </>
);

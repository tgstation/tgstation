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
  translations: Modpack[];
  reverts: Modpack[];
};

type Modpack = {
  name: string;
  desc: string;
  author: string;
  icon_class: string;
};

export const Modpacks = (props) => {
  const { data } = useBackend<Data>();
  const { categories, features, translations, reverts } = data;
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  return (
    <Window title="Список модификаций" width={480} height={580}>
      <NoticeBox>
        В данный момент идёт наполнение меню модпаков, в игре модицикаций больше
        чем вы можете тут видеть.
      </NoticeBox>
      <Window.Content scrollable>
        <Tabs>
          {features.length === 0 ? (
            <NoticeBox>Этот сервер не использует какие-либо прикольные Фичи</NoticeBox>
          ) : (
            <Tabs.Tab
              selected={selectedCategory === 'Features'}
              onClick={() => setSelectedCategory('Features')}
            >
              Фичи и Приколы
            </Tabs.Tab>
          )}
          {translations.length === 0 ? (
            <NoticeBox>Этот сервер не использует какие-либо переводы на Русский</NoticeBox>
          ) : (
            <Tabs.Tab
              selected={selectedCategory === 'Translations'}
              onClick={() => setSelectedCategory('Translations')}
            >
              Переводы на Русский
            </Tabs.Tab>
          )}
          {reverts.length === 0 ? (
            <NoticeBox>Этот сервер не использует какие-либо модификации баланса или ревертов</NoticeBox>
          ) : (
            <Tabs.Tab
              selected={selectedCategory === 'Reverts'}
              onClick={() => setSelectedCategory('Reverts')}
            >
              Балансы и Реверты
            </Tabs.Tab>
          )}
        </Tabs>
        {(selectedCategory === 'Features' && <FeaturesTable />) ||
          (selectedCategory === 'Translations' && <PerevodyTable />) ||
          (selectedCategory === 'Reverts' && <RevertsTable />)
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

const TranslationsTable = () => {
  const { data } = useBackend<Data>();
  const { translations } = data;

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
              <span>Суммарно модификации &mdash; {translations.length}</span>
            )
          }
        >
          <Stack fill vertical>
            <Stack.Item>
              {translations
                .filter(
                  (translate) =>
                    translate.name &&
                    (searchText.length > 0
                      ? translate.name
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        translate.desc
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        translate.author
                          .toLowerCase()
                          .includes(searchText.toLowerCase())
                      : true),
                )
                .map((translate) => (
                  <Collapsible
                    color="transparent"
                    key={translate.name}
                    title={<span class="color-white">{translate.name}</span>}
                  >
                    <Box
                      key={translate.id}
                      style={{
                        borderBottom: '1px solid #888',
                        paddingBottom: '10px',
                        fontSize: '14px',
                        textAlign: 'center',
                      }}
                    >
                      <ModpackItem key={translate.id} translate={translate} />
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

const RevertsTable = () => {
  const { data } = useBackend<Data>();
  const { reverts } = data;

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
              {reverts
                .filter(
                  (revert) =>
                    revert.name &&
                    (searchText.length > 0
                      ? revert.name
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        revert.desc
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        revert.author
                          .toLowerCase()
                          .includes(searchText.toLowerCase())
                      : true),
                )
                .map((revert) => (
                  <Collapsible
                    color="transparent"
                    key={revert.name}
                    title={<span class="color-white">{revert.name}</span>}
                  >
                    <Box
                      key={revert.id}
                      style={{
                        borderBottom: '1px solid #888',
                        paddingBottom: '10px',
                        fontSize: '14px',
                        textAlign: 'center',
                      }}
                    >
                      <ModpackItem key={revert.id} revert={revert} />
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

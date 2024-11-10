// THIS IS A MASSMETA UI FILE

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  LabeledList,
  Input,
  NoticeBox,
  Section,
  Collapsible,
  Stack,
} from '../components';
import { Window } from '../layouts';
  const { act, data } = useBackend();
  const { modpacks = [] } = data;

export const Modpacks = (props, context) => {

  return (
    <Window title="Список модификаций" width={480} height={580}>
      <Window.Content scrollable>
	    <NoticeBox>
            В данный момент идёт наполнение меню модпаков, в игре модицикаций больше чем вы можете тут видеть.
        </NoticeBox>
        {modpacks.length === 0 ? (
          <NoticeBox>
            Этот сервер не использует какие-либо модификации
          </NoticeBox>
        ) : (
          <Stack fill vertical>
            <ModpackList modpacks={modpacks} />
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

const ModpackList = ({ modpacks }) => {
  
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
              <span>Суммарно модификации &mdash; {modpacks.length}</span>
            )
          }
        >
          <Stack fill vertical>
            <Stack.Item>
              {modpacks
                .filter(
                  (modpack) =>
                    modpack.name &&
                    (searchText.length > 0
                      ? modpack.name
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        modpack.desc
                          .toLowerCase()
                          .includes(searchText.toLowerCase()) ||
                        modpack.author
                          .toLowerCase()
                          .includes(searchText.toLowerCase())
                      : true),
                )
                .map((modpack) => (
                  <Collapsible
                    color="transparent"
                    key={modpack.name}
                    title={<span class="color-white">{modpack.name}</span>}
                  >
                    <Box
                      key={modpack.id}
                      style={{
                        borderBottom: '1px solid #888',
                        paddingBottom: '10px',
                        fontSize: '14px',
                        textAlign: 'center',
                      }}
                    >
                      <ModpackItem key={modpack.id} modpack={modpack} />
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

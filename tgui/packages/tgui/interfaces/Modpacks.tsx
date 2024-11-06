// THIS IS A MASSMETA UI FILE

import { useBackend } from '../backend';
import { Box, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const Modpacks = (props) => {
  const { act, data } = useBackend();
  const { modpacks = [] } = data;

  return (
    <Window title="Список модификаций" width={480} height={580}>
      <Window.Content scrollable>
        {modpacks.length === 0 ? (
          <NoticeBox>
            Этот сервер не использует какие-либо модификации
          </NoticeBox>
        ) : (
          <ModpackList modpacks={modpacks} />
        )}
      </Window.Content>
    </Window>
  );
};

const ModpackList = ({ modpacks }) => (
  <Section>
    <LabeledList>
      {modpacks.map((modpack) => (
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
      ))}
    </LabeledList>
  </Section>
);

const ModpackItem = ({ modpack }) => (
  <>
    <LabeledList.Item label="Модуль">{modpack.name}</LabeledList.Item>
    <LabeledList.Item label="Описание">{modpack.desc}</LabeledList.Item>
    <LabeledList.Item label="Автор">{modpack.author}</LabeledList.Item>
  </>
);

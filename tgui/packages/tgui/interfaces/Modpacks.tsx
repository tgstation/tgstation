// THIS IS A MASSMETA UI FILE

import { useBackend } from '../backend';
import { Section, Table, NoticeBox, Tabs } from '../components';
import { Window } from '../layouts';


export const Modpacks = (props) => {
  const { act, data } = useBackend();
  const { modpacks = [] } = data;

  return (
    <Window title="Список модификаций" width={480} height={580}>
      <Window.Content scrollable>
        {(modpacks.length === 0 && (
          <NoticeBox>Этот сервер не использует какие-либо модификации</NoticeBox>
        )) || (
          <Section>
            <Table>
              <Table.Row header>
                <Table.Cell bold>
                  Модуль
                </Table.Cell>
                <Table.Cell bold>
                  Описание
                </Table.Cell>
                <Table.Cell bold>
                  Автор
                </Table.Cell>
              </Table.Row>
              {data.modpacks.map((modpack) => (
                <Table.Row key={modpack.name}>
                  <Table.Cell>
                    {modpack.name}
                  </Table.Cell>
                  <Table.Cell>
                    {modpack.desc}
                  </Table.Cell>
                  <Table.Cell>
                    {modpack.author}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

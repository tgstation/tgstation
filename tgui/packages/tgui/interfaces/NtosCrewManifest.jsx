import { map } from 'es-toolkit/compat';
import { Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { DEPARTMENTS_RU } from '../bandastation/ru_jobs'; // BANDASTATION EDIT
import { NtosWindow } from '../layouts';

export const NtosCrewManifest = (props) => {
  const { act, data } = useBackend();
  const { manifest = {} } = data;
  return (
    <NtosWindow width={400} height={480}>
      <NtosWindow.Content scrollable>
        <Section
          title="Список экипажа"
          buttons={
            <Button
              icon="print"
              content="Распечатать"
              onClick={() => act('PRG_print')}
            />
          }
        >
          {map(manifest, (entries, department) => (
            <Section
              key={department}
              level={2}
              title={DEPARTMENTS_RU[department] || department}
            >
              <Table>
                {entries.map((entry) => (
                  <Table.Row key={entry.name} className="candystripe">
                    <Table.Cell bold>{entry.name}</Table.Cell>
                    <Table.Cell>({entry.rank})</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

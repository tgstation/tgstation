import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosCrewManifest = (props, context) => {
  const { act, data } = useBackend(context);
  const { have_printer, manifest = {} } = data;
  return (
    <NtosWindow width={400} height={480}>
      <NtosWindow.Content scrollable>
        <Section
          title="Crew Manifest"
          buttons={
            <Button
              icon="print"
              content="Print"
              disabled={!have_printer}
              onClick={() => act('PRG_print')}
            />
          }>
          {map((entries, department) => (
            <Section key={department} level={2} title={department}>
              <Table>
                {entries.map((entry) => (
                  <Table.Row key={entry.name} className="candystripe">
                    <Table.Cell bold>{entry.name}</Table.Cell>
                    <Table.Cell>({entry.rank})</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          ))(manifest)}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

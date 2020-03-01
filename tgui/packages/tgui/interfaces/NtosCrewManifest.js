import { useBackend } from '../backend';
import { Button, Section, Table } from '../components';
import { map } from 'common/collections';

export const NtosCrewManifest = props => {
  const { act, data } = useBackend(props);

  const {
    have_printer,
    manifest = {},
  } = data;

  return (
    <Section
      title="Crew Manifest"
      buttons={(
        <Button
          icon="print"
          content="Print"
          disabled={!have_printer}
          onClick={() => act('PRG_print')} />
      )}>
      {map((entries, department) => (
        <Section
          key={department}
          level={2}
          title={department}>
          <Table>
            {entries.map(entry => (
              <Table.Row
                key={entry.name}
                className="candystripe">
                <Table.Cell bold>
                  {entry.name}
                </Table.Cell>
                <Table.Cell>
                  ({entry.rank})
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      ))(manifest)}
    </Section>
  );
};

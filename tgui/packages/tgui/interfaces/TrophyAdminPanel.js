import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../backend';
import { Table } from '../components';
import { Window } from '../layouts';

export const TrophyAdminPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { trophies } = data;
  return (
    <Window title="Trophies Admin Panel" width={800} height={600}>
      <Window.Content scrollable>
        <Table>
          <Table.Row header>
            <Table.Cell color="label">Path</Table.Cell>
            <Table.Cell color="label">Message</Table.Cell>
            <Table.Cell color="label">Placer Key</Table.Cell>
          </Table.Row>
          {!!trophies &&
            trophies.map((trophy) => (
              <Table.Row key={trophy.ref} className="candystripe">
                <Table.Cell
                  style={{
                    'word-break': 'break-all',
                    'word-wrap': 'break-word',
                  }}>
                  {decodeHtmlEntities(trophy.path)}
                </Table.Cell>
                <Table.Cell
                  style={{
                    'word-break': 'break-all',
                    'word-wrap': 'break-word',
                  }}>
                  {decodeHtmlEntities(trophy.message)}
                </Table.Cell>
                <Table.Cell
                  style={{
                    'word-break': 'break-all',
                    'word-wrap': 'break-word',
                  }}>
                  {decodeHtmlEntities(trophy.placer_key)}
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      </Window.Content>
    </Window>
  );
};

import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../backend';
import { Button, Table } from '../components';
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
            <Table.Cell color="label" />
            <Table.Cell color="label">Message</Table.Cell>
            <Table.Cell color="label" />
            <Table.Cell color="label">Placer Key</Table.Cell>
            <Table.Cell color="label" />
          </Table.Row>
          {!!trophies &&
            trophies.map((trophy) => (
              <Table.Row key={trophy.ref} className="candystripe">
                <Table.Cell
                  style={{
                    'word-break': 'break-all',
                    'word-wrap': 'break-word',
                    'color': !trophy.is_valid
                      ? 'rgba(255, 0, 0, 0.5)'
                      : 'inherit',
                  }}>
                  {decodeHtmlEntities(trophy.path)}
                </Table.Cell>
                <Table.Cell>
                  <Button
                    icon="edit"
                    tooltip={'Edit path'}
                    tooltipPosition="bottom"
                    onClick={() => act('edit_path', { ref: trophy.ref })}
                  />
                </Table.Cell>
                <Table.Cell
                  style={{
                    'word-break': 'break-all',
                    'word-wrap': 'break-word',
                  }}>
                  {decodeHtmlEntities(trophy.message)}
                </Table.Cell>
                <Table.Cell>
                  <Button
                    icon="edit"
                    tooltip={'Edit message'}
                    tooltipPosition="bottom"
                    onClick={() => act('edit_message', { ref: trophy.ref })}
                  />
                </Table.Cell>
                <Table.Cell
                  style={{
                    'word-break': 'break-all',
                    'word-wrap': 'break-word',
                  }}>
                  {decodeHtmlEntities(trophy.placer_key)}
                </Table.Cell>
                <Table.Cell>
                  <Button
                    icon="trash"
                    tooltip={'Delete trophy'}
                    tooltipPosition="bottom"
                    onClick={() => act('delete', { ref: trophy.ref })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      </Window.Content>
    </Window>
  );
};

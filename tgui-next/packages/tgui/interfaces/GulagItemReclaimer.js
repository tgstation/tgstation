import { useBackend } from '../backend';
import { Button, Section, Table } from '../components';

export const GulagItemReclaimer = props => {
  const { act, data } = useBackend(props);
  const mobs = data.mobs || [];
  return (
    <Section title="Stored Items">
      <Table>
        {mobs.map(mob => (
          <Table.Row key={mob.mob}>
            <Table.Cell>
              {mob.name}
            </Table.Cell>
            <Table.Cell textAlign="right">
              <Button
                content="Retrieve Items"
                disabled={!data.can_reclaim}
                onClick={() => act('release_items', {
                  mobref: mob.mob,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

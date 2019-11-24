import { act } from '../byond';
import { Button, Section, Table } from '../components';

export const GulagItemReclaimer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const mobs = data.mobs || [];
  return (
    <Section
      title="Stored Items"
      textAlign="center">
      <Table>
        {mobs.map(mob => (
          <Table.Row key={mob.mob}>
            <Table.Cell>
              {mob.name}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content="Retrieve Items"
                disabled={!data.can_reclaim}
                onClick={() => act(ref, 'release_items', {
                  mobref: mob.mob,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

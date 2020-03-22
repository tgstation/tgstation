import { useBackend } from '../backend';
import { Button, NoticeBox, Section, Table } from '../components';

export const GulagItemReclaimer = props => {
  const { act, data } = useBackend(props);
  const {
    mobs = [],
  } = data;

  if (!mobs.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">
          No stored items
        </NoticeBox>
      </Section>
    );
  }

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

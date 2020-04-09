import { useBackend } from '../backend';
import { Button, Section, Table, NoticeBox, Dimmer, Box } from '../components';

export const NtosJobManager = props => {
  const { act, data } = useBackend(props);

  const {
    authed,
    cooldown,
    slots = [],
    prioritized = [],
  } = data;

  if (!authed) {
    return (
      <NoticeBox>
        Current ID does not have access permissions to change job slots.
      </NoticeBox>
    );
  }

  return (
    <Section>
      {cooldown > 0 && (
        <Dimmer>
          <Box
            bold
            textAlign="center"
            fontSize="20px">
            On Cooldown: {cooldown}s
          </Box>
        </Dimmer>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>
            Prioritized
          </Table.Cell>
          <Table.Cell>
            Slots
          </Table.Cell>
        </Table.Row>
        {slots.map(slot => (
          <Table.Row
            key={slot.title}
            className="candystripe">
            <Table.Cell
              bold>
              <Button.Checkbox
                fluid
                content={slot.title}
                disabled={slot.total <= 0}
                checked={slot.total > 0 && prioritized.includes(slot.title)}
                onClick={() => act('PRG_priority', {
                  target: slot.title,
                })}
              />
            </Table.Cell>
            <Table.Cell collapsing>
              {slot.current} / {slot.total}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content="Open"
                disabled={!slot.status_open}
                onClick={() => act('PRG_open_job', {
                  target: slot.title,
                })}
              />
              <Button
                content="Close"
                disabled={!slot.status_close}
                onClick={() => act('PRG_close_job', {
                  target: slot.title,
                })}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

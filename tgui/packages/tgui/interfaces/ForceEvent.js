import { useBackend } from '../backend';
import { Box, Stack, Button, Section, Table } from '../components';
import { Window } from '../layouts';

export const ForceEvent = (props, context) => {
  return (
    <Window title="Force Event" width={450} height={450}>
      <Window.Content scrollable>
        <EventContent />
      </Window.Content>
    </Window>
  );
};

export const EventContent = (props, context) => {
  const { data } = useBackend(context);

  const categories = Object.values(data.categories);

  const nameSorter = (a, b) => {
    const nameA = a.name.toLowerCase();
    const nameB = b.name.toLowerCase();
    if (nameA < nameB) {
      return -1;
    }
    if (nameA > nameB) {
      return 1;
    }
    return 0;
  };

  return (
      <Section>
        <Stack vertical fill>
            {categories.sort(nameSorter).map((category) => (
              <Stack.Item mt={0.2}>
                  <Section title={category.name}>
                    <EventList events={category.events} />
                  </Section>
              </Stack.Item>
            ))}
        </Stack>
      </Section>
  );
};

export const EventList = (props, context) => {
  const { act } = useBackend(context);
  const { events } = props;

  const nameSorter = (a, b) => {
    const nameA = a.name.toLowerCase();
    const nameB = b.name.toLowerCase();
    if (nameA < nameB) {
      return -1;
    }
    if (nameA > nameB) {
      return 1;
    }
    return 0;
  };

  return (
    <Table>
      {events.sort(nameSorter).map((event) => {
        return (
          <Table.Row key={event.name} className="candystripe">
            <Table.Cell>{event.name}</Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Button
                content="Trigger"
                tooltip={event.description || ''}
                tooltipPosition="right"
                onClick={() =>
                  act('forceevent', {
                    type: event.type,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
};

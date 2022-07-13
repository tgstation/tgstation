import { useBackend, useLocalState } from '../backend';
import { Box, Stack, Button, Icon, Input, Section, Table } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';

export const ForceEvent = (props, context) => {
  return (
    <Window title="Force Event" width={450} height={450}>
      <Window.Content scrollable>
      <Stack fill vertical>
          <Stack.Item>
            <EventSearch />
          </Stack.Item>
          <Stack.Item grow>
            <EventContent/>
          </Stack.Item>
      </Stack>
      </Window.Content>
    </Window>
  );
};

export const EventSearch = (props, context) =>  {
  const [searchQuery, setSearchQuery] = useLocalState(
    context,
    'searchQuery',
    ''
  );

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Icon name="search" />
        </Stack.Item>
        <Stack.Item grow>
          <Input
            autoFocus
            fluid
            onInput={(e) => setSearchQuery(e.target.value)}
            placeholder="Search..."
            value={searchQuery}
          />
        </Stack.Item>
      </Stack>
    </Section>
  )
}

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
                    <EventList category={category} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
  );
};

export const EventList = (props, context) => {
  const { act } = useBackend(context);
  const { category } = props;

  const [searchQuery, setSearchQuery] = useLocalState(
    context,
    'searchQuery',
    ''
  );

  const filtered_events = flow([
    filter((event) => event.name?.toLowerCase().includes(searchQuery.toLowerCase())),
    sortBy((event) => event.name),
  ])(category.events || []);

  if (!filtered_events.length) {
    return null;
  }

  return (
    
    <Section title={category.name}>
      <Table>
        {filtered_events.map((event) => {
          return (
            <Table.Row key={event.name} className="candystripe">
              <Table.Cell>{event.name}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  mt={0.2}
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
    </Section>
  );
};

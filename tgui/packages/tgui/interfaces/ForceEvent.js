import { useBackend, useLocalState } from '../backend';
import { Stack, Button, Icon, Input, Section, Table } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';

export const ForceEvent = (props, context) => {
  return (
    <Window title="Force Event" width={450} height={450}>
      <Window.Content scrollable>
        <EventSearch />
        <EventOptionsPanel />
        <EventContent />
      </Window.Content>
    </Window>
  );
};

export const EventSearch = (props, context) => {
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
  );
};

export const EventOptionsPanel = (props, context) => {
  const { data } = useBackend(context);

  const [announce, setAnnounce] = useLocalState(context, 'announce', true);

  return (
    <Button.Checkbox
      fluid
      checked={announce}
      onClick={() => setAnnounce(!announce)}>
      Announce event to the crew
    </Button.Checkbox>
  );
};

export const EventContent = (props, context) => {
  const { data } = useBackend(context);

  const categories = Object.values(data.categories);
  const sortCategories = sortBy((category) => category.name);

  return sortCategories(categories).map((category) => (
    <EventList category={category} key={category.name} />
  ));
};

export const EventList = (props, context) => {
  const { act } = useBackend(context);
  const { category } = props;
  const [searchQuery] = useLocalState(context, 'searchQuery', '');
  const [announce] = useLocalState(context, 'announce', true);

  const filtered_events = flow([
    filter((event) =>
      event.name?.toLowerCase().includes(searchQuery.toLowerCase())
    ),
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
                      announce: announce,
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

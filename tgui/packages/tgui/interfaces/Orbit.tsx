import { Window } from '../layouts';
import { Box, Button, Icon, Input, NoticeBox, Section, Stack, Table } from '../components';
import { useBackend, useLocalState } from '../backend';
import { multiline } from 'common/string';

type Data = {
  alive: Observable[];
  antagonists: Observable[];
  dead: Observable[];
  ghosts: Observable[];
  misc: Observable[];
  npcs: Observable[];
};

type Observable = {
  ref: string;
  name: string;
  orbiters: number;
};

const TITLES = [
  { name: 'Antagonists', color: 'bad' },
  { name: 'Alive', color: 'good' },
  { name: 'Dead', color: 'grey' },
  { name: 'Ghosts', color: 'grey' },
  { name: 'Misc', color: 'grey' },
  { name: 'NPCs', color: 'average' },
] as const;

enum THREAT {
  None,
  Small = 'blue',
  Medium = 'cyan',
  Large = 'purple',
}

export const Orbit = (props, context) => {
  return (
    <Window title="Orbit" width={400} height={550}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item mt={0}>
            <ObservableSearch />
          </Stack.Item>
          <Stack.Item mt={0.2} grow>
            <Section fill scrollable>
              <ObservableContent />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Controls filtering out the list of observables via search */
const ObservableSearch = (props, context) => {
  const { act } = useBackend<Data>(context);
  const [autoObserve, setAutoObserve] = useLocalState<boolean>(
    context,
    'autoObserve',
    false
  );
  const [searchQuery, setSearchQuery] = useLocalState<string>(
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
            placeholder="Search..."
            value={searchQuery}
            onInput={(e) => setSearchQuery(e.target.value)}
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Button
            color={autoObserve ? 'good' : 'transparent'}
            icon={autoObserve ? 'toggle-on' : 'toggle-off'}
            onClick={() => setAutoObserve(!autoObserve)}
            tooltip={multiline`Toggle Auto-Observe. When active, you'll
            see the UI / full inventory of whoever you're orbiting. Neat!`}
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            inline
            color="transparent"
            tooltip="Refresh"
            tooltipPosition="bottom-start"
            icon="sync-alt"
            onClick={() => act('refresh')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** The primary section of observable content, iterates over all POIs */
const ObservableContent = (props, context) => {
  const { data } = useBackend<Data>(context);
  const {
    alive = [],
    antagonists = [],
    dead = [],
    ghosts = [],
    misc = [],
    npcs = [],
  } = data;
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );
  let visibleSections = [antagonists, alive, dead, ghosts, misc, npcs];
  if (searchQuery) {
    visibleSections = getFilteredLists(visibleSections, searchQuery);
    if (!visibleSections.length) {
      return <NoticeBox>Nothing to display!</NoticeBox>;
    }
  }

  return (
    <Stack vertical>
      {visibleSections?.map((section, index) => {
        const { name, color } = TITLES[index];
        return (
          !!section.length && (
            <Stack.Item key={index}>
              <ObservableSection color={color} name={name} section={section} />
            </Stack.Item>
          )
        );
      })}
    </Stack>
  );
};

/** Displays an individual section for observable items */
const ObservableSection = (props, context) => {
  const { color, name, section } = props;

  return (
    <Section
      title={
        <Box color={color} italic>
          {name} ({section.length})
        </Box>
      }>
      {section.map((observable, index) => {
        return (
          <ObservableItem color={color} key={index} observable={observable} />
        );
      })}
    </Section>
  );
};

/** An individual listing for an observable's name, # observers */
const ObservableItem = (props, context) => {
  const { act } = useBackend<Data>(context);
  const { color, observable } = props;
  const { ref, name, orbiters } = observable;
  const [autoObserve, setAutoObserve] = useLocalState<boolean>(
    context,
    'autoObserve',
    false
  );
  const threat = getThreat(orbiters);

  return (
    <Button
      color={threat || color}
      mt={0}
      mb={0}
      onClick={() => act('orbit', { auto_observe: autoObserve, ref: ref })}>
      <Table>
        <Table.Row>
          <Table.Cell>{nameToUpper(name)}</Table.Cell>
          {orbiters && (
            <>
              <Table.Cell>{orbiters.toString()}</Table.Cell>
              <Table.Cell>
                <Icon
                  name={threat === THREAT.Large ? 'skull' : 'ghost'}
                  spin={threat === THREAT.Medium}
                />
              </Table.Cell>
            </>
          )}
        </Table.Row>
      </Table>
    </Button>
  );
};

/** Takes the amount of orbiters and returns some style options */
const getThreat = (orbiters: number): THREAT => {
  if (!orbiters || orbiters <= 2) {
    return THREAT.None;
  } else if (orbiters === 3) {
    return THREAT.Small;
  } else if (orbiters <= 6) {
    return THREAT.Medium;
  } else {
    return THREAT.Large;
  }
};

/**
 * Filters both lists for the search query.
 *
 * Returns:
 *  an array of Observable[]
 */
const getFilteredLists = (lists: Observable[][], searchQuery: string) => {
  let filteredLists: Observable[][] = [];
  for (const list of lists) {
    const filtered = list.filter((observable) => {
      return observable.name
        ?.toLowerCase()
        ?.includes(searchQuery?.toLowerCase());
    });
    filteredLists.push(filtered);
  }
  return filteredLists;
};

/**
 * Returns a string with the first letter in uppercase.
 * Unlike capitalize(), has no effect on the other letters
 */
const nameToUpper = (name: string) =>
  name.replace(/^\w/, (c) => c.toUpperCase());

import { Window } from '../layouts';
import { Box, Button, Collapsible, Icon, Input, Section, Stack, Table } from '../components';
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
  antag?: string;
  name: string;
  orbiters?: number;
};

type Title = {
  name: string;
  color: string;
};

const COLLAPSING_TITLES: readonly Title[] = [
  { name: 'Dead', color: 'grey' },
  { name: 'Ghosts', color: 'grey' },
  { name: 'Misc', color: 'grey' },
  { name: 'NPCs', color: 'average' },
] as const;

const ANTAG_GROUPS = {
  'Nuclear Operative': 'Nuclear Operatives',
  'Nuclear Leader': 'Nuclear Operatives',
  'Abductor Scientist': 'Abductors',
  'Abductor Agent': 'Abductors',
};

enum THREAT {
  None,
  Small = 'teal',
  Medium = 'blue',
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
  const { act, data } = useBackend<Data>(context);
  const {
    alive = [],
    antagonists = [],
    dead = [],
    ghosts = [],
    misc = [],
    npcs = [],
  } = data;
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
  /** Gets a list of Observable[], then filters the most relevant to orbit */
  const orbitMostRelevant = (searchText: string) => {
    const sources: Observable[][] = [
      alive,
      antagonists,
      ghosts,
      dead,
      npcs,
      misc,
    ].filter((source) => {
      return source.length > 0;
    });
    const mostRelevant = getFilteredLists(sources, searchText)
      .flat()
      .sort(sortByOrbiters)[0];
    if (mostRelevant !== undefined) {
      act('orbit', {
        ref: mostRelevant.ref,
        auto_observe: autoObserve,
      });
    }
  };

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
            onEnter={(e, value) => orbitMostRelevant(value)}
            onInput={(e) => setSearchQuery(e.target.value)}
            placeholder="Search..."
            value={searchQuery}
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

/**
 * The primary content display for points of interest. Renders a scrollable
 * section that filters results based on search queries. Colors and groups
 * together backend data.
 */
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
  let collapsibleSections = [dead, ghosts, misc, npcs];
  let visibleSections: Observable[][] = [];
  let visibleTitles: Title[] = [];
  /** This collates antagonists into their own groups */
  if (antagonists.length) {
    sortAntagonists(antagonists).map(([name, antag]) => {
      visibleSections.push(antag);
      visibleTitles.push({ name, color: 'bad' });
    });
  }
  /** Adds living players to the end of the primary sections*/
  visibleSections.push(alive);
  visibleTitles.push({ name: 'Alive', color: 'good' });
  /** Handles filtering out search results. */
  if (searchQuery) {
    visibleSections = getFilteredLists(visibleSections, searchQuery);
    collapsibleSections = getFilteredLists(collapsibleSections, searchQuery);
  }

  return (
    <Stack vertical>
      <PrimarySections sections={visibleSections} titles={visibleTitles} />
      <CollapsingSections sections={collapsibleSections} />
    </Stack>
  );
};

/** Displays a primary antag or alive section */
const PrimarySections = (props, context) => {
  const { sections = [], titles = [] } = props;

  return sections?.map((section, index) => {
    const { color, name } = titles[index];
    return (
      !!section.length && (
        <Stack.Item key={index}>
          <Section
            title={
              <Box color={color}>
                {name} ({section.length})
              </Box>
            }>
            <ObservableMap color={color} index={index} section={section} />
          </Section>
        </Stack.Item>
      )
    );
  });
};

/** Displays a collapsible section for ghosts, NPCs, etc. */
const CollapsingSections = (props, context) => {
  const { sections = [] } = props;

  return sections?.map((section, index) => {
    const { color, name } = COLLAPSING_TITLES[index];
    return (
      !!section.length && (
        <Stack.Item key={index}>
          <Collapsible
            color={color}
            title={name + ` (${section.length})`}
            section={section}>
            <ObservableMap color={color} section={section} />
          </Collapsible>
        </Stack.Item>
      )
    );
  });
};

/** Displays a map of observable items */
const ObservableMap = (props, context) => {
  const { act } = useBackend<Data>(context);
  const { color, section = [] } = props;
  const [autoObserve, setAutoObserve] = useLocalState<boolean>(
    context,
    'autoObserve',
    false
  );

  return section?.map((observable, index) => {
    const { name, orbiters, ref } = observable;
    const threat = getThreat(orbiters);
    return (
      <Button
        color={threat || color}
        key={index}
        mt={0}
        mb={0}
        onClick={() => act('orbit', { auto_observe: autoObserve, ref: ref })}>
        <Table>
          <Table.Row>
            <Table.Cell>{nameToUpper(name).slice(0, 44)}</Table.Cell>
            {orbiters && (
              <>
                <Table.Cell>({orbiters.toString()}</Table.Cell>
                <Table.Cell>
                  <Icon
                    mr={0}
                    name={threat === THREAT.Large ? 'skull' : 'ghost'}
                  />
                  )
                </Table.Cell>
              </>
            )}
          </Table.Row>
        </Table>
      </Button>
    );
  });
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
const getFilteredLists = (
  lists: Observable[][],
  searchQuery: string
): Observable[][] => {
  let filteredLists: Observable[][] = [];
  lists.map((list) => {
    const filtered = list.filter((observable) => {
      return observable.name
        ?.toLowerCase()
        ?.includes(searchQuery?.toLowerCase());
    });
    filteredLists.push(filtered);
  });
  return filteredLists;
};

/** Sorts by the highest orbiter count */
const sortByOrbiters = (a: Observable, b: Observable): number => {
  if (!a.orbiters && !b.orbiters) {
    return 0;
  }
  if (!a.orbiters) {
    return 1;
  }
  if (!b.orbiters) {
    return -1;
  }
  return a.orbiters - b.orbiters;
};

/**
 * Returns a string with the first letter in uppercase.
 * Unlike capitalize(), has no effect on the other letters
 */
const nameToUpper = (name: string): string =>
  name.replace(/^\w/, (c) => c.toUpperCase());

/** Compares a string and returns a number value if there is a match. */
const compareString = (a: string, b: string): number =>
  a > b ? 1 : a < b ? -1 : 0;

/**
 * Collates antagonist groups into their own separate sections.
 * Some antags are grouped together lest they be listed separately,
 * ie: Nuclear Operatives. See: ANTAG_GROUPS.
 */
const sortAntagonists = (
  antagonists: Observable[]
): [string, Observable[]][] => {
  const collatedAntagonists = {};
  for (const antagonist of antagonists) {
    const { antag } = antagonist;
    const resolvedName = ANTAG_GROUPS[antag!] || antag;
    if (collatedAntagonists[resolvedName] === undefined) {
      collatedAntagonists[resolvedName] = [];
    }
    collatedAntagonists[resolvedName].push(antagonist);
  }
  const sortedAntagonists: [string, Observable[]][] =
    Object.entries(collatedAntagonists);
  sortedAntagonists.sort((a, b) => {
    return compareString(a[0], b[0]);
  });
  return sortedAntagonists;
};

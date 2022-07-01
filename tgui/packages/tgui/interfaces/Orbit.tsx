import { useBackend, useLocalState } from '../backend';
import { filter, sortBy } from 'common/collections';
import { multiline } from 'common/string';
import { Box, Button, Collapsible, Icon, Input, Section, Stack } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';

type AntagGroup = [string, Observable[]];

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

type SectionProps = {
  collapsible?: boolean;
  color?: string;
  section: Observable[];
  title: string;
};

const ANTAG2COLOR = {
  'Abductors': 'pink',
  'Ash Walkers': 'olive',
  'Biohazards': 'brown',
} as const;

const ANTAG2GROUP = {
  'Abductor Agent': 'Abductors',
  'Abductor Scientist': 'Abductors',
  'Ash Walker': 'Ash Walkers',
  'Blob': 'Biohazards',
  'Sentient Disease': 'Biohazards',
  'Clown Operative': 'Clown Operatives',
  'Clown Operative Leader': 'Clown Operatives',
  'Nuclear Operative': 'Nuclear Operatives',
  'Nuclear Operative Leader': 'Nuclear Operatives',
  'Space Wizard': 'Wizard Federation',
  'Wizard Apprentice': 'Wizard Federation',
  'Wizard Minion': 'Wizard Federation',
} as const;

enum THREAT {
  None,
  Small = 'teal',
  Medium = 'blue',
  Large = 'violet',
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
  const orbitMostRelevant = (searchQuery: string): void => {
    /** Returns the most orbited observable that matches the search. */
    const mostRelevant: Observable = flow([
      // Filters out anything that doesn't match search
      filter<Observable>((observable) =>
        observable.name?.includes(searchQuery?.toLowerCase())
      ),
      // Sorts descending by orbiters
      sortBy<Observable>((poi) => -(poi.orbiters || 0)),
      // Makes a single Observable[] list for an easy search
    ])([alive, antagonists, dead, ghosts, misc, npcs].flat());
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
 * The primary content display for points of interest.
 * Renders a scrollable section replete with subsections for each
 * observable group.
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
  let collatedAntagonists: AntagGroup[] = [];
  if (antagonists.length) {
    collatedAntagonists = collateAntagonists(antagonists);
  }

  return (
    <Stack vertical>
      {collatedAntagonists?.map(([name, antag]) => {
        return (
          <ObservableSection
            color={ANTAG2COLOR[name] || 'bad'}
            key={name}
            section={antag}
            title={name}
          />
        );
      })}
      <ObservableSection color="good" section={alive} title="Alive" />
      <ObservableSection collapsible section={dead} title="Dead" />
      <ObservableSection collapsible section={ghosts} title="Ghosts" />
      <ObservableSection collapsible section={misc} title="Misc" />
      <ObservableSection
        collapsible
        color="average"
        section={npcs}
        title="NPCs"
      />
    </Stack>
  );
};

/**
 * Displays a primary section for antags and living players.
 * Filters the results if there is a provided search query.
 */
const ObservableSection = (props: SectionProps, context) => {
  const { collapsible = false, color = 'grey', section = [], title } = props;
  if (!section.length) {
    return null;
  }
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );
  const filteredSection: Observable[] = flow([
    filter<Observable>((poi) =>
      poi.name?.toLowerCase().includes(searchQuery?.toLowerCase())
    ),
    sortBy<Observable>((poi) => poi.name.toLowerCase()),
  ])(section);
  if (!filteredSection.length) {
    return null;
  }
  return (
    <Stack.Item>
      {!collapsible ? (
        <Section
          title={
            <Box color={color}>
              {title} - ({filteredSection.length})
            </Box>
          }>
          <ObservableMap color={color} section={filteredSection} />
        </Section>
      ) : (
        <Collapsible
          bold
          color={color}
          title={title + ` - (${filteredSection.length})`}>
          <ObservableMap color={color} section={filteredSection} />
        </Collapsible>
      )}
    </Stack.Item>
  );
};

/** Renders all of the observables in sorted order */
const ObservableMap = (
  props: { color: string; section: Observable[] },
  context
) => {
  const { act } = useBackend<Data>(context);
  const { color, section = [] } = props;
  const [autoObserve, setAutoObserve] = useLocalState<boolean>(
    context,
    'autoObserve',
    false
  );

  return (
    <div>
      {section?.map((observable, index) => {
        const { name, orbiters, ref } = observable;
        const threat = getThreat(orbiters || 0);
        return (
          <Button
            color={threat || color}
            key={index}
            onClick={() =>
              act('orbit', { auto_observe: autoObserve, ref: ref })
            }>
            {nameToUpper(name).slice(0, 44) /** prevents it from overflowing */}
            {!!orbiters && (
              <>
                {' '}
                ({orbiters.toString()}{' '}
                <Icon
                  mr={0}
                  name={threat === THREAT.Large ? 'skull' : 'ghost'}
                />
                )
              </>
            )}
          </Button>
        );
      })}
    </div>
  );
};

/**
 * Collates antagonist groups into their own separate sections.
 * Some antags are grouped together lest they be listed separately,
 * ie: Nuclear Operatives. See: ANTAG_GROUPS.
 */
const collateAntagonists = (antagonists: Observable[]): AntagGroup[] => {
  const collatedAntagonists = {};
  for (const antagonist of antagonists) {
    const { antag } = antagonist;
    const resolvedName = ANTAG2GROUP[antag!] || antag;
    if (collatedAntagonists[resolvedName] === undefined) {
      collatedAntagonists[resolvedName] = [];
    }
    collatedAntagonists[resolvedName].push(antagonist);
  }
  const sortedAntagonists = sortBy<AntagGroup>((antagonist) => antagonist[0])(
    Object.entries(collatedAntagonists)
  );

  return sortedAntagonists;
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
 * Returns a string with the first letter in uppercase.
 * Unlike capitalize(), has no effect on the other letters
 */
const nameToUpper = (name: string): string =>
  name.replace(/^\w/, (c) => c.toUpperCase());

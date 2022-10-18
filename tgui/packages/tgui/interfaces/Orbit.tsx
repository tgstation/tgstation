import { useBackend, useLocalState } from '../backend';
import { filter, sortBy } from 'common/collections';
import { capitalizeFirst, multiline } from 'common/string';
import { Box, Button, Collapsible, Icon, Input, LabeledList, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';

type AntagGroup = [string, Antags];

type Antags = Array<Observable & { antag: string }>;

type Data = {
  alive: Array<Observable>;
  antagonists: Antags;
  dead: Array<Observable>;
  ghosts: Array<Observable>;
  misc: Array<Observable>;
  npcs: Array<Observable>;
};

type Observable = {
  extra?: string;
  full_name: string;
  health?: number;
  job?: string;
  name?: string;
  orbiters?: number;
  ref: string;
};

const ANTAG2COLOR = {
  'Abductors': 'pink',
  'Ash Walkers': 'olive',
  'Biohazards': 'brown',
  'CentCom': 'teal',
} as const;

const ANTAG2GROUP = {
  'Abductor Agent': 'Abductors',
  'Abductor Scientist': 'Abductors',
  'Ash Walker': 'Ash Walkers',
  'Blob': 'Biohazards',
  'Sentient Disease': 'Biohazards',
  'CentCom Commander': 'CentCom',
  'CentCom Head Intern': 'CentCom',
  'CentCom Intern': 'CentCom',
  'CentCom Official': 'CentCom',
  'Central Command': 'CentCom',
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
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item mt={0}>
            <ObservableSearch />
          </Stack.Item>
          <Stack.Item mt={0.2} grow>
            <Section fill>
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
  /** Gets a list of Observables, then filters the most relevant to orbit */
  const orbitMostRelevant = (searchQuery: string): void => {
    /** Returns the most orbited observable that matches the search. */
    const mostRelevant: Observable = flow([
      // Filters out anything that doesn't match search
      filter<Observable>((observable) =>
        isJobOrNameMatch(observable, searchQuery)
      ),
      // Sorts descending by orbiters
      sortBy<Observable>((observable) => -(observable.orbiters || 0)),
      // Makes a single Observables list for an easy search
    ])([alive, antagonists, dead, ghosts, misc, npcs].flat())[0];
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
  let collatedAntagonists: Array<AntagGroup> = [];
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
      <ObservableSection section={dead} title="Dead" />
      <ObservableSection section={ghosts} title="Ghosts" />
      <ObservableSection section={misc} title="Misc" />
      <ObservableSection section={npcs} title="NPCs" />
    </Stack>
  );
};

/**
 * Displays a collapsible with a map of observable items.
 * Filters the results if there is a provided search query.
 */
const ObservableSection = (
  props: {
    color?: string;
    section: Array<Observable>;
    title: string;
  },
  context
) => {
  const { color = 'grey', section = [], title } = props;
  if (!section.length) {
    return null;
  }
  const [searchQuery] = useLocalState<string>(context, 'searchQuery', '');
  const filteredSection: Array<Observable> = flow([
    filter<Observable>((observable) =>
      isJobOrNameMatch(observable, searchQuery)
    ),
    sortBy<Observable>((observable) => observable.name?.toLowerCase()),
  ])(section);
  if (!filteredSection.length) {
    return null;
  }

  return (
    <Stack.Item>
      <Collapsible
        bold
        color={color}
        open={color !== 'grey'}
        title={title + ` - (${filteredSection.length})`}>
        {filteredSection.map((poi, index) => {
          return <ObservableItem color={color} item={poi} key={index} />;
        })}
      </Collapsible>
    </Stack.Item>
  );
};

/** Renders an observable button that has tooltip info for living Observables*/
const ObservableItem = (
  props: { color: string; item: Observable },
  context
) => {
  const { act } = useBackend<Data>(context);
  const { color, item } = props;
  const { extra, full_name, health, name, orbiters, ref } = item;
  const [autoObserve] = useLocalState<boolean>(context, 'autoObserve', false);
  const threat = getThreat(orbiters ?? 0);
  const displayName = getDisplayName(name, full_name);

  return (
    <Button
      color={threat || color}
      onClick={() => act('orbit', { auto_observe: autoObserve, ref: ref })}
      tooltip={(!!health || !!extra) && <ObservableTooltip item={item} />}
      tooltipPosition="bottom-start">
      {capitalizeFirst(displayName)}
      {!!orbiters && (
        <>
          {' '}
          ({orbiters}{' '}
          <Icon mr={0} name={threat === THREAT.Large ? 'skull' : 'ghost'} />)
        </>
      )}
    </Button>
  );
};

/** Displays some info on the mob as a tooltip. */
const ObservableTooltip = (props: { item: Observable }) => {
  const {
    item: { extra, full_name, job, health },
  } = props;
  const extraInfo = extra?.split(':');

  return (
    <>
      <NoticeBox textAlign="center" nowrap>
        Last Known Data
      </NoticeBox>
      <LabeledList>
        {!!extraInfo && (
          <LabeledList.Item label={extraInfo[0]}>
            {extraInfo[1]}
          </LabeledList.Item>
        )}
        {!!full_name && (
          <LabeledList.Item label="Name">{full_name}</LabeledList.Item>
        )}
        {!!job && <LabeledList.Item label="Job">{job}</LabeledList.Item>}
        {!!health && (
          <LabeledList.Item label="Health">
            {getHealthLabel(health!)}
          </LabeledList.Item>
        )}
      </LabeledList>
    </>
  );
};

/**
 * Collates antagonist groups into their own separate sections.
 * Some antags are grouped together lest they be listed separately,
 * ie: Nuclear Operatives. See: ANTAG_GROUPS.
 */
const collateAntagonists = (antagonists: Antags) => {
  const collatedAntagonists = {}; // Hate that I cant use a map here
  antagonists.map((player) => {
    const { antag } = player;
    const resolvedName: string = ANTAG2GROUP[antag] || antag;
    if (!collatedAntagonists[resolvedName]) {
      collatedAntagonists[resolvedName] = [];
    }
    collatedAntagonists[resolvedName].push(player);
  });
  const sortedAntagonists = sortBy<AntagGroup>(([key]) => key)(
    Object.entries(collatedAntagonists)
  );

  return sortedAntagonists;
};

/** Returns a disguised name in case the person is wearing someone else's ID */
const getDisplayName = (name: string | undefined, full_name: string) => {
  if (!name) {
    return full_name;
  }
  if (
    !full_name?.includes('[') ||
    full_name.match(/\(as /) ||
    full_name.match(/^Unknown/)
  ) {
    return name;
  }
  // return only the name before the first ' [' or ' ('
  return `"${full_name.split(/ \[| \(/)[0]}"`;
};

/** Returns some labels for a player's health */
const getHealthLabel = (health: number) => {
  if (health >= 100) {
    return <Box color="blue">Great</Box>;
  }
  if (health >= 75) {
    return <Box color="green">Good</Box>;
  }
  if (health >= 50) {
    return <Box color="yellow">Fair</Box>;
  }
  if (health >= 25) {
    return <Box color="orange">Poor</Box>;
  }
  if (health > 0) {
    return <Box color="orange">Bad</Box>;
  }
  if (health <= 0) {
    return <Box color="red">Critical</Box>;
  }
};

/** Takes the amount of orbiters and returns some style options */
const getThreat = (orbiters: number) => {
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

/** Checks if a full name or job title matches the search. */
const isJobOrNameMatch = (observable: Observable, searchQuery: string) => {
  const { full_name, name, job } = observable;
  const displayName = full_name ?? name;

  return (
    displayName?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    job?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    false
  );
};

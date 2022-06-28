import { Window } from '../layouts';
import { Box, Button, Icon, Input, NoticeBox, Section, Stack, Table, Tabs } from '../components';
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

enum Tab {
  Alive,
  Dead,
  Misc,
}

const GroupNames = [
  ['Antagonists', 'Alive'],
  ['Ghosts', 'Dead'],
  ['Misc', 'NPCs'],
] as const;

export const Orbit = (props, context) => {
  return (
    <Window title="Orbit" width={350} height={550}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <ObservableTabs />
          </Stack.Item>
          <Stack.Item grow>
            <ObservableSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Set of tabs at the top of the UI that controls which lists are shown. */
const ObservableTabs = (props, context) => {
  const [tab, setTab] = useLocalState<Tab>(context, 'tab', Tab.Alive);

  return (
    <Tabs fluid>
      <Tabs.Tab onClick={() => setTab(Tab.Alive)} selected={tab === Tab.Alive}>
        Alive
      </Tabs.Tab>
      <Tabs.Tab onClick={() => setTab(Tab.Dead)} selected={tab === Tab.Dead}>
        Dead
      </Tabs.Tab>
      <Tabs.Tab onClick={() => setTab(Tab.Misc)} selected={tab === Tab.Misc}>
        Misc
      </Tabs.Tab>
    </Tabs>
  );
};

/** The primary section for displaying and searching observables */
const ObservableSection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
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
  const [tab, setTab] = useLocalState<Tab>(context, 'tab', Tab.Alive);
  const currentLists = getCurrentLists(tab, data);

  return (
    <Section
      buttons={
        <>
          <Input
            autoFocus
            placeholder="Search"
            value={searchQuery}
            onInput={(e) => setSearchQuery(e.target.value)}
          />

          <Button
            color={autoObserve ? 'good' : 'transparent'}
            icon={autoObserve ? 'toggle-on' : 'toggle-off'}
            onClick={() => setAutoObserve(!autoObserve)}
            tooltip={multiline`Toggle Auto-Observe. When active, you'll
            see the UI / full inventory of whoever you're orbiting. Neat!`}
            tooltipPosition="bottom-start"
          />
          <Button
            inline
            color="transparent"
            tooltip="Refresh"
            tooltipPosition="bottom-start"
            icon="sync-alt"
            onClick={() => act('refresh')}
          />
        </>
      }
      fill
      title="Observables">
      <ObservableContent list={currentLists} />
    </Section>
  );
};

/** Controls filtering out the list of observables via search */
const ObservableContent = (props, context) => {
  const { list } = props;
  const [searchQuery, setSearchQuery] = useLocalState(
    context,
    'searchQuery',
    ''
  );
  const [tab, setTab] = useLocalState(context, 'tab', Tab.Alive);
  let filteredObservables: [Observable[], Observable[]] = [[], []];
  // Do we have a search query? Filter each list.
  if (searchQuery) {
    const poiGroupA: Observable[] = list[0].filter((observable) => {
      return observable.name
        ?.toLowerCase()
        ?.includes(searchQuery?.toLowerCase());
    });
    const poiGroupB: Observable[] = list[1].filter((observable) => {
      return observable.name
        ?.toLowerCase()
        ?.includes(searchQuery?.toLowerCase());
    });
    filteredObservables = [poiGroupA, poiGroupB];
  }
  const displayedList = searchQuery ? filteredObservables : list;
  const sectionTitle = GroupNames[tab];
  const listsEmpty = !displayedList[0]?.length && !displayedList[1]?.length;

  return (
    <Stack fill vertical>
      {listsEmpty ? (
        <NoticeBox>Nothing to display!</NoticeBox>
      ) : (
        displayedList?.map((list, index) => {
          return (
            !!list.length && (
              <Stack.Item grow key={index}>
                <TableDisplay list={list} title={sectionTitle[index]} />
              </Stack.Item>
            )
          );
        })
      )}
    </Stack>
  );
};

/** The actual list component which simply displays a list based on props */
const TableDisplay = (props, context) => {
  const { list, title } = props;

  return (
    <Section
      color="label"
      fill
      scrollable
      title={
        <Box italic color="good" ml={7}>
          {title}
        </Box>
      }>
      {!!list?.length && (
        <Table>
          {list.map((observable, index) => {
            return <TableRow key={index} observable={observable} />;
          })}
        </Table>
      )}
    </Section>
  );
};

/** An individual listing for an observable's name, # observers */
const TableRow = (props: { observable: Observable }, context) => {
  const { act } = useBackend<Data>(context);
  const { observable } = props;
  const { ref, name, orbiters } = observable;
  const [autoObserve, setAutoObserve] = useLocalState<boolean>(
    context,
    'autoObserve',
    false
  );
  // You're probably wondering why not use capitalize here. Well, it's because
  // capitalize will lowercase other letters in the string.
  const nameToUpper = (name: string) =>
    name.replace(/^\w/, (c) => c.toUpperCase());

  return (
    <Table.Row
      className="candystripe"
      onClick={() => act('orbit', { auto_observe: autoObserve, ref: ref })}>
      <Table.Cell width="100%">{nameToUpper(name)}</Table.Cell>
      <Table.Cell p={1}>
        <Stack>
          <Stack.Item color={getColor(orbiters)}>{orbiters}</Stack.Item>
          <Stack.Item>
            <Icon name="ghost" />
          </Stack.Item>
        </Stack>
      </Table.Cell>
    </Table.Row>
  );
};

/** Returns an array of two Observable[] lists based on the tabs. */
const getCurrentLists = (tab: Tab, data: Data) => {
  const { alive, antagonists, dead, ghosts, misc, npcs } = data;
  switch (tab) {
    case Tab.Alive:
      return [antagonists, alive];
    case Tab.Dead:
      return [dead, ghosts];
    case Tab.Misc:
      return [misc, npcs];
    default:
      return alive;
  }
};

/** Colorizes the amount of orbiters */
const getColor = (orbiters: number) => {
  if (!orbiters) {
    return null;
  } else if (orbiters < 2) {
    return 'label';
  } else if (orbiters < 4) {
    return 'good';
  } else if (orbiters < 6) {
    return 'average';
  } else {
    return 'bad';
  }
};

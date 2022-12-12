import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { capitalizeFirst, multiline } from 'common/string';
import { useBackend, useLocalState } from 'tgui/backend';
import { Button, Collapsible, Icon, Input, LabeledList, NoticeBox, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { JobToIcon } from '../common/JobToIcon';
import { ANTAG2COLOR } from './constants';
import { collateAntagonists, getDisplayColor, getDisplayName, isJobOrNameMatch } from './helpers';
import type { AntagGroup, Observable, OrbitData } from './types';

export const Orbit = (props, context) => {
  return (
    <Window title="Orbit" width={400} height={550}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
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
  const { act, data } = useBackend<OrbitData>(context);
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
  const [heatMap, setHeatMap] = useLocalState<boolean>(
    context,
    'heatMap',
    false
  );
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );

  /** Gets a list of Observables, then filters the most relevant to orbit */
  const orbitMostRelevant = (searchQuery: string) => {
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
            color="transparent"
            icon={!heatMap ? 'heart' : 'ghost'}
            onClick={() => setHeatMap(!heatMap)}
            tooltip={multiline`Toggles between highlighting health or
            orbiters.`}
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
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
            color="transparent"
            icon="sync-alt"
            onClick={() => act('refresh')}
            tooltip="Refresh"
            tooltipPosition="bottom-start"
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
  const { data } = useBackend<OrbitData>(context);
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
      <ObservableSection color="blue" section={alive} title="Alive" />
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
    section: Observable[];
    title: string;
  },
  context
) => {
  const { color, section = [], title } = props;

  if (!section.length) {
    return null;
  }

  const [searchQuery] = useLocalState<string>(context, 'searchQuery', '');

  const filteredSection: Observable[] = flow([
    filter<Observable>((observable) =>
      isJobOrNameMatch(observable, searchQuery)
    ),
    sortBy<Observable>((observable) =>
      getDisplayName(observable.full_name, observable.name)
        .replace(/^"/, '')
        .toLowerCase()
    ),
  ])(section);

  if (!filteredSection.length) {
    return null;
  }

  return (
    <Stack.Item>
      <Collapsible
        bold
        color={color ?? 'grey'}
        open={!!color}
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
  props: { color?: string; item: Observable },
  context
) => {
  const { act } = useBackend<OrbitData>(context);
  const { color, item } = props;
  const { extra, full_name, job, job_icon, health, name, orbiters, ref } = item;

  const [autoObserve] = useLocalState<boolean>(context, 'autoObserve', false);
  const [heatMap] = useLocalState<boolean>(context, 'heatMap', false);

  return (
    <Button
      color={getDisplayColor(item, heatMap, color)}
      icon={job_icon || (job && JobToIcon[job]) || null}
      onClick={() => act('orbit', { auto_observe: autoObserve, ref: ref })}
      tooltip={(!!health || !!extra) && <ObservableTooltip item={item} />}
      tooltipPosition="bottom-start">
      {capitalizeFirst(getDisplayName(full_name, name))}
      {!!orbiters && (
        <>
          {' '}
          <Icon mr={0} name={'ghost'} />
          {orbiters}
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
  const displayHealth = !!health && health >= 0 ? `${health}%` : 'Critical';

  return (
    <>
      <NoticeBox textAlign="center" nowrap>
        Last Known Data
      </NoticeBox>
      <LabeledList>
        {extraInfo ? (
          <LabeledList.Item label={extraInfo[0]}>
            {extraInfo[1]}
          </LabeledList.Item>
        ) : (
          <>
            {!!full_name && (
              <LabeledList.Item label="Name">{full_name}</LabeledList.Item>
            )}
            {!!job && <LabeledList.Item label="Job">{job}</LabeledList.Item>}
            {!!health && (
              <LabeledList.Item label="Health">
                {displayHealth}
              </LabeledList.Item>
            )}
          </>
        )}
      </LabeledList>
    </>
  );
};

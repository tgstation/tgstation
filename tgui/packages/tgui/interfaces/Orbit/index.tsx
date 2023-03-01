import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { capitalizeFirst, multiline } from 'common/string';
import { useBackend, useLocalState } from 'tgui/backend';
import { Button, Collapsible, Icon, Input, LabeledList, NoticeBox, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { JOB2ICON } from '../common/JobToIcon';
import { ANTAG2COLOR } from './constants';
import { getAntagCategories, getDisplayColor, getDisplayName, getMostRelevant, isJobOrNameMatch } from './helpers';
import type { AntagGroup, Antagonist, Observable, OrbitData } from './types';

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
    deadchat_controlled = [],
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
    const mostRelevant = getMostRelevant(searchQuery, [
      alive,
      antagonists,
      deadchat_controlled,
      dead,
      ghosts,
      misc,
      npcs,
    ]);

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
    deadchat_controlled = [],
    dead = [],
    ghosts = [],
    misc = [],
    npcs = [],
  } = data;

  let collatedAntagonists: AntagGroup[] = [];

  if (antagonists.length) {
    collatedAntagonists = getAntagCategories(antagonists);
  }

  return (
    <Stack vertical>
      {collatedAntagonists?.map(([title, antagonists]) => {
        return (
          <ObservableSection
            color={ANTAG2COLOR[title] || 'bad'}
            key={title}
            section={antagonists}
            title={title}
          />
        );
      })}
      <ObservableSection
        color="purple"
        section={deadchat_controlled}
        title="Deadchat Controlled"
      />
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
  const { extra, full_name, job, health, name, orbiters, ref } = item;

  const [autoObserve] = useLocalState<boolean>(context, 'autoObserve', false);
  const [heatMap] = useLocalState<boolean>(context, 'heatMap', false);

  return (
    <Button
      color={getDisplayColor(item, heatMap, color)}
      icon={(job && JOB2ICON[job]) || null}
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
const ObservableTooltip = (props: { item: Observable | Antagonist }) => {
  const { item } = props;
  const { extra, full_name, health, job } = item;
  let antag;
  if ('antag' in item) {
    antag = item.antag;
  }

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
              <LabeledList.Item label="Real ID">{full_name}</LabeledList.Item>
            )}
            {!!job && !antag && (
              <LabeledList.Item label="Job">{job}</LabeledList.Item>
            )}
            {!!antag && (
              <LabeledList.Item label="Threat">{antag}</LabeledList.Item>
            )}
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

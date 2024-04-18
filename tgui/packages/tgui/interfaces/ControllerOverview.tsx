import { BooleanLike } from 'common/react';
import { createSearch } from 'common/string';
import { useMemo, useState } from 'react';

import { useBackend } from '../backend';
import {
  Button,
  Collapsible,
  Dropdown,
  Input,
  LabeledList,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type SubsystemData = {
  name: string;
  ref: string;
  init_order: number;
  last_fire: number;
  next_fire: number;
  can_fire: BooleanLike;
  doesnt_fire: BooleanLike;
  cost_ms: number;
  tick_usage: number;
  tick_overrun: number;
  initialized: BooleanLike;
  initialization_failure_message: string | undefined;
};

type ControllerData = {
  world_time: number;
  fast_update: BooleanLike;
  map_cpu: number;
  subsystems: SubsystemData[];
};

const SubsystemView = (props: { data: SubsystemData }) => {
  const { act } = useBackend();
  const { data } = props;
  const {
    name,
    ref,
    init_order,
    last_fire,
    next_fire,
    can_fire,
    doesnt_fire,
    cost_ms,
    tick_usage,
    tick_overrun,
    initialized,
    initialization_failure_message,
  } = data;

  let icon = 'play';
  if (!initialized) {
    icon = 'circle-exclamation';
  } else if (doesnt_fire) {
    icon = 'check';
  } else if (!can_fire) {
    icon = 'pause';
  }

  return (
    <Collapsible
      title={name}
      key={ref}
      icon={icon}
      buttons={
        <Button
          icon="wrench"
          tooltip="View Variables"
          onClick={() => {
            act('view_variables', { ref: ref });
          }}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Init Order">{init_order}</LabeledList.Item>
        <LabeledList.Item label="Last Fire">{last_fire}</LabeledList.Item>
        <LabeledList.Item label="Next Fire">{next_fire}</LabeledList.Item>
        <LabeledList.Item label="Cost">{cost_ms}ms</LabeledList.Item>
        <LabeledList.Item label="Tick Usage">
          {(tick_usage * 0.01).toFixed(2)}%
        </LabeledList.Item>
        <LabeledList.Item label="Tick Overrun">
          {(tick_overrun * 0.01).toFixed(2)}%
        </LabeledList.Item>
        {initialization_failure_message ? (
          <LabeledList.Item color="bad">
            {initialization_failure_message}
          </LabeledList.Item>
        ) : undefined}
      </LabeledList>
    </Collapsible>
  );
};

enum SubsystemSortBy {
  INIT_ORDER = 'Init Order',
  NAME = 'Name',
  LAST_FIRE = 'Last Fire',
  NEXT_FIRE = 'Next Fire',
  TICK_USAGE = 'Tick Usage',
  TICK_OVERRUN = 'Tick Overrun',
  COST = 'Cost',
}

const sortSubsystemBy = (
  subsystems: SubsystemData[],
  sortBy: SubsystemSortBy,
  asending: boolean = true,
) => {
  let sorted = subsystems.sort((left, right) => {
    switch (sortBy) {
      case SubsystemSortBy.INIT_ORDER:
        return left.init_order - right.init_order;
      case SubsystemSortBy.NAME:
        return left.name.localeCompare(right.name);
      case SubsystemSortBy.LAST_FIRE:
        return left.last_fire - right.last_fire;
      case SubsystemSortBy.NEXT_FIRE:
        return left.next_fire - right.next_fire;
      case SubsystemSortBy.TICK_USAGE:
        return left.tick_usage - right.tick_usage;
      case SubsystemSortBy.TICK_OVERRUN:
        return left.tick_overrun - right.tick_overrun;
      case SubsystemSortBy.COST:
        return left.cost_ms - right.cost_ms;
    }
  });
  if (!asending) {
    sorted.reverse();
  }
  return sorted;
};

export const ControllerOverview = () => {
  const { act, data } = useBackend<ControllerData>();
  const { world_time, map_cpu, subsystems, fast_update } = data;

  const [filterName, setFilterName] = useState('');
  const [sortBy, setSortBy] = useState(SubsystemSortBy.NAME);
  const [sortAscending, setSortAscending] = useState<boolean>(true);

  let filteredSubsystems = useMemo(() => {
    if (!filterName) {
      return subsystems;
    }

    return subsystems.filter(() =>
      createSearch(filterName, (subsystem: SubsystemData) => subsystem.name),
    );
  }, [filterName, subsystems]);

  let sortedSubsystems = useMemo(() => {
    return sortSubsystemBy(filteredSubsystems, sortBy, sortAscending);
  }, [sortBy, sortAscending, filteredSubsystems]);

  const overallUsage = subsystems.reduce(
    (acc, subsystem) => acc + subsystem.tick_usage,
    0,
  );
  const overallOverrun = subsystems.reduce(
    (acc, subsystem) => acc + subsystem.tick_overrun,
    0,
  );

  return (
    <Window>
      <Window.Content>
        <Section title="Master Overview">
          <Stack vertical>
            <Stack.Item>World Time: {world_time}</Stack.Item>
            <Stack.Item>Map CPU: {map_cpu.toFixed(2)}%</Stack.Item>
            <Stack.Item>
              Overall Usage: {(overallUsage * 0.01).toFixed(2)}%
            </Stack.Item>
            <Stack.Item>
              Overall Overrun: {(overallOverrun * 0.01).toFixed(2)}%
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title="Filtering/Sorting"
          buttons={
            <Button
              tooltip="Fast Update"
              icon="fast-forward"
              color={fast_update ? 'good' : 'bad'}
              onClick={() => {
                act('toggle_fast_update');
              }}
            />
          }
        >
          <Input
            placeholder="Filter by name"
            value={filterName}
            onChange={(e, value) => setFilterName(value)}
          />
          <Button
            icon="trash"
            tooltip="Reset filter"
            onClick={() => setFilterName('')}
            disabled={filterName === undefined}
          />
          <Dropdown
            options={Object.values(SubsystemSortBy)}
            selected={sortBy}
            onSelected={(value) => setSortBy(value as SubsystemSortBy)}
          />
          <Stack>
            <Stack.Item>
              <Button
                selected={sortAscending}
                onClick={() => setSortAscending(true)}
              >
                Ascending
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                selected={!sortAscending}
                onClick={() => setSortAscending(false)}
              >
                Descending
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Subsystem Overview" scrollable>
          <Stack vertical>
            {sortedSubsystems.map((subsystem) => (
              <SubsystemView key={subsystem.ref} data={subsystem} />
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

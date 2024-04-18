import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Button,
  Collapsible,
  Dropdown,
  Input,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type SubsystemData = {
  ref: string;
  init_order: number;
  last_fire: number;
  next_fire: number;
  can_fire: boolean;
  doesnt_fire: boolean;
  cost_ms: number;
  tick_usage: number;
  tick_overrun: number;
  initialized: boolean;
  initialization_failure_message: string | undefined;
};

type ControllerData = {
  world_time: number;
  fast_update: boolean;
  map_cpu: number;
  subsystems: Record<string, SubsystemData>;
};

const SubsystemView = (props: { name: string; data: SubsystemData }) => {
  const { act } = useBackend();
  const { name, data } = props;

  let icon = 'play';
  if (!data.initialized) {
    icon = 'circle-exclamation';
  } else if (data.doesnt_fire) {
    icon = 'check';
  } else if (!data.can_fire) {
    icon = 'pause';
  }

  return (
    <Collapsible
      title={name}
      key={data.ref}
      icon={icon}
      buttons={
        <Button
          icon="wrench"
          tooltip="View Variables"
          onClick={() => {
            act('view_variables', { ref: data.ref });
          }}
        />
      }
    >
      <Stack vertical>
        <Stack.Item>Init Order: {data.init_order}</Stack.Item>
        <Stack.Item>Last Fire: {data.last_fire}</Stack.Item>
        <Stack.Item>Next Fire: {data.next_fire}</Stack.Item>
        <Stack.Item>Cost: {data.cost_ms}ms</Stack.Item>
        <Stack.Item>
          Tick Usage: {(data.tick_usage * 0.01).toFixed(2)}%
        </Stack.Item>
        <Stack.Item>
          Tick Overrun: {(data.tick_overrun * 0.01).toFixed(2)}%
        </Stack.Item>
        {data.initialization_failure_message ? (
          <Stack.Item color="bad">
            {data.initialization_failure_message}
          </Stack.Item>
        ) : undefined}
      </Stack>
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
}

const sortSubsystemBy = (
  subsystems: Record<string, SubsystemData>,
  sortBy: SubsystemSortBy,
  asending: boolean = true,
) => {
  let sorted = Object.entries(subsystems).sort(
    ([nameA, subsystemA], [nameB, subsystemB]) => {
      switch (sortBy) {
        case SubsystemSortBy.INIT_ORDER:
          return subsystemA.init_order - subsystemB.init_order;
        case SubsystemSortBy.NAME:
          return nameA.localeCompare(nameB);
        case SubsystemSortBy.LAST_FIRE:
          return subsystemA.last_fire - subsystemB.last_fire;
        case SubsystemSortBy.NEXT_FIRE:
          return subsystemA.next_fire - subsystemB.next_fire;
        case SubsystemSortBy.TICK_USAGE:
          return subsystemA.tick_usage - subsystemB.tick_usage;
        case SubsystemSortBy.TICK_OVERRUN:
          return subsystemA.tick_overrun - subsystemB.tick_overrun;
      }
    },
  );
  if (!asending) {
    sorted = sorted.reverse();
  }
  return Object.fromEntries(sorted);
};

export const ControllerOverview = () => {
  const { act, data } = useBackend<ControllerData>();
  const { world_time, map_cpu, subsystems } = data;

  const [filterName, setFilterName] = useState<string | undefined>(undefined);
  const [sortBy, setSortBy] = useState<SubsystemSortBy>(SubsystemSortBy.NAME);
  const [sortAscending, setSortAscending] = useState<boolean>(true);

  let filteredSubsystems = subsystems;
  if (filterName !== undefined) {
    filteredSubsystems = Object.fromEntries(
      Object.entries(subsystems).filter(([name, subsystem]) =>
        name.toLowerCase().includes(filterName.toLowerCase()),
      ),
    );
  }
  filteredSubsystems = sortSubsystemBy(
    filteredSubsystems,
    sortBy,
    sortAscending,
  );

  const overallUsage = Object.values(subsystems).reduce(
    (acc, subsystem) => acc + subsystem.tick_usage,
    0,
  );
  const overallOverrun = Object.values(subsystems).reduce(
    (acc, subsystem) => acc + subsystem.tick_overrun,
    0,
  );

  return (
    <Window>
      <Window.Content scrollable>
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
              color={data.fast_update ? 'good' : 'bad'}
              onClick={() => {
                act('toggle_fast_update');
              }}
            />
          }
        >
          <Input
            placeholder="Filter by name"
            value={filterName}
            onChange={(e, value) =>
              setFilterName(value.length > 0 ? value : undefined)
            }
          />
          <Button
            icon="trash"
            tooltip="Reset filter"
            onClick={() => setFilterName(undefined)}
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
        <Section title="Subsystem Overview">
          <Stack vertical>
            {Object.entries(filteredSubsystems).map(([name, data]) => (
              <SubsystemView key={name} name={name} data={data} />
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

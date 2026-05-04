import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Image,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
  VirtualList,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';
import { type BooleanLike, classes } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import type { Material } from './Fabrication/Types';

type Machine = {
  name: string;
  icon: string;
  on_hold: boolean;
  location: string;
};

type UserData = {
  name: string;
  age: number;
  assignment: string;
  account_id: number;
  account_holder: string;
  account_assignment: string;
  accesses: string[];
  chamelon_override: string | null;
  silicon_override: string | null;
  id_read_failure: string | null;
};

type Log = {
  raw_materials: string;
  machine_name: string;
  area_name: string;
  action: string;
  amount: number;
  time: string;
  noun: string;
  user_data: UserData;
};

enum Tab {
  Machines,
  Logs,
}

type Data = {
  SHEET_MATERIAL_AMOUNT: number;
  materials: Material[];
  machines: Machine[];
  logs: Log[];
  // Banned users is a list of bank account datum IDs
  banned_users: number[];
  ID_required: BooleanLike;
};

const actionToColor = {
  DEPOSITED: 'green',
  WITHDRAWN: 'red',
  PROCESSED: 'blue',
  RESTOCKED: 'purple',
};

export const OreSilo = (props: Data) => {
  const { act, data } = useBackend<Data>();
  const { SHEET_MATERIAL_AMOUNT, machines, logs } = data;

  const [currentTab, setCurrentTab] = useState<Tab>(Tab.Logs);

  return (
    <Window title="Ore Silo" width={620} height={600}>
      <Window.Content className="OreSilo">
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="plug"
                selected={currentTab === Tab.Machines}
                onClick={() => setCurrentTab(Tab.Machines)}
              >
                Connections
              </Tabs.Tab>
              <Tabs.Tab
                icon="book-bookmark"
                selected={currentTab === Tab.Logs}
                onClick={() => setCurrentTab(Tab.Logs)}
              >
                Logs
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {currentTab === Tab.Machines ? (
              <MachineList
                machines={machines!}
                onPause={(index) => act('hold', { id: index })}
                onRemove={(index) => act('remove', { id: index })}
              />
            ) : null}
            {currentTab === Tab.Logs && <LogsList logs={logs} />}
          </Stack.Item>
          <Stack.Item>
            <Section fill>
              <MaterialAccessBar
                availableMaterials={data.materials}
                SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                onEjectRequested={(material, amount) =>
                  act('eject', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type MachineListProps = {
  machines: Machine[];
  onPause: (index: number) => void;
  onRemove: (index: number) => void;
};

const MachineList = (props: MachineListProps) => {
  const { machines, onPause, onRemove } = props;

  return machines.length > 0 ? (
    <Section fill scrollable>
      {machines.map((machine, index) => (
        <MachineDisplay
          key={index}
          machine={machine}
          onPause={() => onPause(index + 1)}
          onRemove={() => onRemove(index + 1)}
        />
      ))}
    </Section>
  ) : (
    <NoticeBox>No machines connected!</NoticeBox>
  );
};

type MachineProps = {
  machine: Machine;
  onPause: () => void;
  onRemove: () => void;
};

const MachineDisplay = (props: MachineProps) => {
  const { machine, onPause, onRemove } = props;

  let machineName = machine.name;
  const index = machineName.indexOf('('); // some techfabs have their location attached to their name
  if (index >= 0) {
    machineName = machineName.substring(0, index);
  }
  machineName = `${machineName.trimEnd()} (${machine.location})`;

  return (
    <Box className="FabricatorRecipe">
      <Box
        className={
          machine.on_hold
            ? classes([
                'FabricatorRecipe__Title',
                'FabricatorRecipe__Title--disabled',
              ])
            : 'FabricatorRecipe__Title'
        }
      >
        <Box className="FabricatorRecipe__Icon">
          <Image
            width={'32px'}
            height={'32px'}
            src={`data:image/jpeg;base64,${machine.icon}`}
          />
        </Box>
        <Box className="FabricatorRecipe__Label">{machineName}</Box>
      </Box>

      <Tooltip
        content={
          machine.on_hold
            ? `Resume ${machine.name} usage.`
            : `Put ${machine.name} on hold.`
        }
      >
        <Box
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
          ])}
          onClick={(_) => {
            onPause();
          }}
        >
          <Icon name={machine.on_hold ? 'circle-play' : 'circle-pause'} />
        </Box>
      </Tooltip>
      <Tooltip content={`Disconnect ${machine.name}.`}>
        <Box
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
          ])}
          onClick={(_) => {
            onRemove();
          }}
        >
          <Icon name="trash-can" />
        </Box>
      </Tooltip>
    </Box>
  );
};

type LogsListProps = {
  logs: Log[];
};

const RestrictButton = () => {
  const { act, data } = useBackend<Data>();
  const { ID_required } = data;
  return (
    <Box align="center">
      <Button
        position="relative"
        className="__RestrictButton"
        color={ID_required ? 'bad' : 'good'}
        onClick={() => act('toggle_restrict')}
        style={{
          marginLeft: 'auto',
          right: 0,
        }}
      >
        {ID_required ? 'Disable ID Requirement' : 'Enable ID Requirement'}
      </Button>
    </Box>
  );
};

const LogsList = (props: LogsListProps) => {
  const { logs } = props;

  const searchableLogs = logs.map((log, index) => ({
    id: index,
    log,
    searchString: [
      log.action.toLowerCase(),
      log.user_data.name.toLowerCase(),
      log.user_data.assignment.toLowerCase(),
      log.raw_materials.toLowerCase(),
      log.machine_name.toLowerCase(),
      log.area_name.toLowerCase(),
      log.noun.toLowerCase(),
    ].join(' '),
  }));

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: searchableLogs,
    matchStrategy: 'smart',
    getSearchString: (item) => item.searchString,
  });

  const filteredLogs = query ? results.map((result) => result.log) : logs;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Action Logs" buttons={<RestrictButton />}>
          <Stack>
            <Stack.Item grow>
              <Input
                fluid
                height={1.7}
                autoFocus
                placeholder="Search for names, locations and resources..."
                value={query}
                onChange={(value) => setQuery(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="close"
                onClick={() => setQuery('')}
                disabled={!query}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable={filteredLogs.length > 0} pr={1}>
          {filteredLogs.length > 0 ? (
            <VirtualList>
              {filteredLogs.map((log, index) => (
                <LogEntry key={index} {...log} />
              ))}
            </VirtualList>
          ) : (
            <NoticeBox textAlign="center">
              {query
                ? 'No logs seem to match your request.'
                : 'Nothing here...'}
            </NoticeBox>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const UserItem = (props: UserData) => {
  const {
    name = 'NAME_RES_FAIL',
    age = 0,
    assignment = 'ASSGN-RES_FAIL',
    account_id = 0,
    account_holder,
    account_assignment,
    accesses,
    chamelon_override,
    silicon_override,
    id_read_failure,
  } = props;
  const { act, data } = useBackend<Data>();
  const { banned_users } = data;
  return (
    <Stack align="center">
      <Stack.Item>{name},</Stack.Item>
      <Stack.Item>{assignment}</Stack.Item>
      {!id_read_failure && !silicon_override && (
        <Stack.Item>
          <Button
            color={banned_users.includes(account_id) ? 'bad' : 'good'}
            onClick={() => act('toggle_ban', { user_data: props })}
            lineHeight={1.6}
          >
            {banned_users.includes(account_id) ? 'Unrestrict' : 'Restrict'}{' '}
            access
          </Button>
        </Stack.Item>
      )}
    </Stack>
  );
};

const formatAmount = (action: string, amount: number) => {
  const isSheetAction = action === 'WITHDRAWN' || action === 'DEPOSITED';
  const rawAmount = Math.abs(amount);
  if (!isSheetAction) {
    return rawAmount;
  }
  const proportionalAmount = rawAmount / 100;
  return ` ${proportionalAmount} `;
};

const LogEntry = (props: Log) => {
  const {
    raw_materials,
    machine_name,
    area_name,
    action,
    amount,
    time,
    noun,
    user_data,
  } = props;
  const [expanded, setExpanded] = useState(false);

  return (
    <Box>
      <Box
        style={{
          cursor: 'pointer',
        }}
        onClick={() => setExpanded(!expanded)}
      >
        <Stack align="center" style={{ padding: '0.5em' }}>
          <Stack.Item>
            <Button
              disabled
              icon={expanded ? 'arrow-down' : 'arrow-right'}
              color="disabled"
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              color={actionToColor[action.toUpperCase()]}
              width="8em"
              textAlign="center"
            >
              {action.toUpperCase()}
            </Button>
          </Stack.Item>
          <Stack.Item style={{ display: 'flex', alignItems: 'center' }}>
            <Icon name="arrow-right" ml={1} mr={1} />
          </Stack.Item>
          <Stack.Item grow style={{ display: 'flex', alignItems: 'center' }}>
            {` ${formatAmount(action, amount)} ${noun}`}
          </Stack.Item>
          <Stack.Item style={{ display: 'flex', alignItems: 'center' }}>
            <Button icon="user" color="gray">
              {user_data.name} ({user_data.assignment})
            </Button>
          </Stack.Item>
        </Stack>
      </Box>

      {expanded && (
        <Box mt={0.5}>
          <Table>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Time</Table.Cell>
              <Table.Cell>{time}</Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Machine</Table.Cell>
              <Table.Cell>{capitalize(machine_name)}</Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Location</Table.Cell>
              <Table.Cell>{area_name}</Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Materials</Table.Cell>
              <Table.Cell color={amount > 0 ? 'good' : 'bad'}>
                {raw_materials}
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>User</Table.Cell>
              <Table.Cell>
                <UserItem {...user_data} />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Box>
      )}
    </Box>
  );
};

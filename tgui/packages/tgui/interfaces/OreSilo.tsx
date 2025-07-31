import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Icon,
  Image,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
  VirtualList,
} from 'tgui-core/components';
import { BooleanLike, classes } from 'tgui-core/react';
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
  id_required: BooleanLike;
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
            {currentTab === Tab.Logs && (
              <>
                <RestrictButton />
                <LogsList logs={logs} />
              </>
            )}
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
  const { id_required } = data;
  return (
    <Box align="center">
      <Button
        position="relative"
        className="__RestrictButton"
        color={id_required ? 'bad' : 'good'}
        onClick={() => act('toggle_restrict')}
      >
        {id_required ? 'Disable ID Requirement' : 'Enable ID Requirement'}
      </Button>
    </Box>
  );
};

const LogsList = (props: LogsListProps) => {
  const { logs } = props;

  return logs.length > 0 ? (
    <Section fill scrollable pr={1} align="center">
      <Divider />
      <VirtualList>
        {logs.map((log, index) => (
          <LogEntry key={index} {...log} />
        ))}
      </VirtualList>
    </Section>
  ) : (
    <NoticeBox>No log entries currently present!</NoticeBox>
  );
};

const UserItem = (props: UserData) => {
  const {
    name,
    age,
    assignment,
    account_id,
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
    <Stack align="center" className="__UserItem">
      <Stack.Item className="__Name">{name}</Stack.Item>
      <Stack.Item className="__Assignment">{assignment}</Stack.Item>
      {!id_read_failure && !silicon_override && (
        <Stack.Item>
          <Button
            className="__AntiRoboticistButton" // we have fun here
            color={banned_users.includes(account_id) ? 'bad' : 'good'}
            onClick={() => act('toggle_ban', { user_data: props })}
          >
            {banned_users.includes(account_id) ? 'Unban' : 'Ban'} User?
          </Button>
        </Stack.Item>
      )}
    </Stack>
  );
};

const formatAmount = (action: string, amount: number) => {
  const isSheetAction = action === 'EJECT' || action === 'DEPOSIT';
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
  return (
    <Collapsible
      title={`${action.toUpperCase()} ${formatAmount(action, amount)} ${noun}, [${user_data.name} | ${user_data.assignment.toUpperCase()}]`}
    >
      <Section className="__LogEntry">
        <LabeledList>
          <LabeledList.Item label="Time">{time}</LabeledList.Item>
          <LabeledList.Item label="Machine">
            {capitalize(machine_name)}
          </LabeledList.Item>
          <LabeledList.Item label="Location">{area_name}</LabeledList.Item>
          <LabeledList.Item
            label="Materials"
            color={amount > 0 ? 'good' : 'bad'}
          >
            {raw_materials}
          </LabeledList.Item>
          <LabeledList.Item label="User">
            <UserItem {...user_data} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Collapsible>
  );
};

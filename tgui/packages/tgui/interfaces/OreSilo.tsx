import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
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
import { classes } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { Material } from './Fabrication/Types';

type Machine = {
  name: string;
  icon: string;
  onHold: boolean;
  location: string;
};

type UserData = {
  Name: string;
  Age: number;
  Assignment: string;
  Account_ID: number;
  Account_Holder: string;
  Account_Assignment: string;
  Accesses: string[];
  chamelon_override: string | null;
  silicon_override: string | null;
  id_read_failure: string | null;
};

type Log = {
  rawMaterials: string;
  machineName: string;
  areaName: string;
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
};

export const OreSilo = (props: any) => {
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
            {currentTab === Tab.Logs ? <LogsList logs={logs!} /> : null}
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
          machine.onHold
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
          machine.onHold
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
          <Icon name={machine.onHold ? 'circle-play' : 'circle-pause'} />
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

const LogsList = (props: LogsListProps) => {
  const { logs } = props;

  return logs.length > 0 ? (
    <Section fill scrollable pr={1} height="100%">
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

const EntryTitle = (log: Log) => {
  const { action, amount, noun, user_data } = log;

  const Verb = (
    <Box as="span" className="__actionPart">
      {action}
    </Box>
  );

  const formatAmount = (action: string, amount: number) => {
    const isSheetAction = action === 'EJECT' || action === 'DEPOSIT';
    const rawAmount = Math.abs(amount);
    if (!isSheetAction) {
      return rawAmount;
    }
    const proportionalAmount = rawAmount / 100;
    return ` ${proportionalAmount} `;
  };

  const Noun = (
    <Box as="span" className="__nounPart">
      {noun}
    </Box>
  );

  return (
    <>
      {
        <Box as="span" style={{ textTransform: 'uppercase' }}>
          {Verb}
        </Box>
      }{' '}
      {formatAmount(action, amount)} {Noun}
      {', '}
      {'['}
      {user_data.Name}
      {' | '}
      {
        <Box
          as="span"
          style={{
            textTransform: 'uppercase',
          }}
        >
          {user_data.Assignment}
        </Box>
      }
      {']'}
    </>
  );
};

const UserItem = (user_data: UserData) => {
  const {
    Name,
    Age,
    Assignment,
    Account_ID,
    Account_Holder,
    Account_Assignment,
    Accesses,
    chamelon_override,
    silicon_override,
    id_read_failure,
  } = user_data;
  const { act, data } = useBackend<Data>();
  const { banned_users } = data;
  return (
    <Stack align="center" className="__UserItem">
      <Stack.Item>
        <Box className="__Name">{Name}</Box>
      </Stack.Item>
      <Stack.Item>
        <Box className="__Assignment">{Assignment}</Box>
      </Stack.Item>
      {(!id_read_failure && !silicon_override) ? (
        <Stack.Item>
          <Button
            className="__AntiRoboticistButton"
            color={banned_users.includes(Account_ID) ? 'bad' : 'good'}
            onClick={() => act('toggle_ban', { user_data: user_data })}
          >
            {banned_users.includes(Account_ID) ? 'Unban' : 'Ban'} User?
          </Button>
        </Stack.Item>
      ) : null}
    </Stack>
  );
};

const LogEntry = (props: Log) => {
  const { rawMaterials, machineName, areaName, amount, time, user_data } =
    props;
  return (
    <Collapsible title={EntryTitle(props)}>
      <Section className="__LogEntry">
        <LabeledList>
          <LabeledList.Item label="Time">{time}</LabeledList.Item>
          <LabeledList.Item label="Machine">
            {capitalize(machineName)}
          </LabeledList.Item>
          <LabeledList.Item label="Location">{areaName}</LabeledList.Item>
          <LabeledList.Item
            label="Materials"
            color={amount > 0 ? 'good' : 'bad'}
          >
            {rawMaterials}
          </LabeledList.Item>
          <LabeledList.Item label="User">
            <UserItem {...user_data} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Collapsible>
  );
};

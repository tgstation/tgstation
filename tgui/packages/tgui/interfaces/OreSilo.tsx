import { classes } from 'common/react';
import { capitalize } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Icon,
  Image,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { Material } from './Fabrication/Types';

type Machine = {
  name: string;
  icon: string;
  onHold: boolean;
  location: string;
};

type Log = {
  rawMaterials: string;
  machineName: string;
  areaName: string;
  action: string;
  amount: number;
  time: string;
  noun: string;
};

type OreSiloData = {
  SHEET_MATERIAL_AMOUNT: number;
  materials: Material[];
  machines: Machine[];
  logs: Log[];
};

export const OreSilo = (props: any) => {
  const { act, data } = useBackend<OreSiloData>();
  const { SHEET_MATERIAL_AMOUNT, machines, logs } = data;

  const [currentTab, setCurrentTab] = useState(0);

  return (
    <Window title="Ore Silo" width={620} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="plug"
                selected={currentTab === 0}
                onClick={() => setCurrentTab(0)}
              >
                Connections
              </Tabs.Tab>
              <Tabs.Tab
                icon="book-bookmark"
                selected={currentTab === 1}
                onClick={() => setCurrentTab(1)}
              >
                Logs
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {currentTab === 0 ? (
              !!machines && machines.length > 0 ? (
                <Section fill scrollable>
                  {machines.map((machine, index) => (
                    <MachineDisplay
                      key={index}
                      machine={machine}
                      onPause={() => act('hold', { id: index + 1 })}
                      onRemove={() => act('remove', { id: index + 1 })}
                    />
                  ))}
                </Section>
              ) : (
                <NoticeBox>No machines connected!</NoticeBox>
              )
            ) : null}
            {currentTab === 1 ? (
              !!logs && logs.length > 0 ? (
                <Box pr={1} height="100%" overflowY="scroll">
                  {logs.map((log, index) => (
                    <LogEntry key={index} log={log} />
                  ))}
                </Box>
              ) : (
                <NoticeBox>No log entries currently present!</NoticeBox>
              )
            ) : null}
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
  machineName = `${machineName.trimEnd()}(${machine.location})`;

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

type LogProps = {
  log: Log;
};

const LogEntry = (props: LogProps) => {
  const { log } = props;
  return (
    <Section
      title={`${capitalize(log.action)}: x${Math.abs(log.amount)} ${log.noun}`}
    >
      <LabeledList>
        <LabeledList.Item label="Time">{log.time}</LabeledList.Item>
        <LabeledList.Item label="Machine">
          {capitalize(log.machineName)}
        </LabeledList.Item>
        <LabeledList.Item label="Location">{log.areaName}</LabeledList.Item>
        <LabeledList.Item
          label="Materials"
          color={log.amount > 0 ? 'good' : 'bad'}
        >
          {log.rawMaterials}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

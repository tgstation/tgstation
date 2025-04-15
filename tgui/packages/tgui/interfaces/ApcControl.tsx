import { sortBy } from 'common/collections';
import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AreaCharge, powerRank } from './PowerMonitor';

enum Screen {
  ControlPanel = 1,
  LogView,
}

type APC = {
  name: string;
  operating: BooleanLike;
  charge: number;
  load: string;
  charging: number;
  chargeMode: number;
  eqp: number;
  lgt: number;
  env: number;
  responds: BooleanLike;
  ref: string;
};

type Log = {
  entry: string;
};

type Data = {
  authenticated: BooleanLike;
  emagged: BooleanLike;
  logging: BooleanLike;
  restoring: BooleanLike;
  apcs: APC[];
  logs: Log[];
};

export function ApcControl(props) {
  const { data } = useBackend<Data>();
  const { authenticated } = data;

  return (
    <Window title="APC Controller" width={550} height={500}>
      <Window.Content>
        {authenticated ? <ApcLoggedIn /> : <ApcLoggedOut />}
      </Window.Content>
    </Window>
  );
}

function ApcLoggedOut(props) {
  const { act, data } = useBackend<Data>();
  const { emagged } = data;
  const text = emagged ? 'Open' : 'Log In';

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item grow>
          <Stack fill vertical justify="center" align="center">
            <Stack.Item>
              <Icon name="bolt-lightning" color="yellow" size={8} />
            </Stack.Item>
            <Stack.Item bold mt={5}>
              Zeus™ Controller Version 0.19
            </Stack.Item>
            <Stack.Item color="label">Copyright 2526 Nanotrasen</Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item color="#2a2a2a">
          Nanotrasen and its affiliates do not endorse this product. Risk of
          serious bodily injury or death is inherent in the use of any device
          that generates electricity. Nanotrasen is not responsible for any
          damages caused by the use of this product.
        </Stack.Item>
        <Stack.Item>
          <NoticeBox
            m={0}
            mt={1}
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
            }}
          >
            Authorized personnel only.
            <Button
              icon="sign-in-alt"
              color={emagged ? '' : 'good'}
              onClick={() => act('log-in')}
            >
              {text}
            </Button>
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function ApcLoggedIn(props) {
  const { act, data } = useBackend<Data>();
  const { restoring } = data;

  const [tabIndex, setTabIndex] = useState<Screen>(Screen.ControlPanel);
  const sortByState = useState('name');

  return (
    <Stack fill vertical g={0}>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === Screen.ControlPanel}
            onClick={() => {
              setTabIndex(Screen.ControlPanel);
              act('check-apcs');
            }}
          >
            APC Control Panel
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === Screen.LogView}
            onClick={() => {
              setTabIndex(Screen.LogView);
              act('check-logs');
            }}
          >
            Log View Panel
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      {!!restoring && (
        <Dimmer fontSize="32px">
          <Icon name="cog" spin />
          {' Resetting...'}
        </Dimmer>
      )}
      <Stack.Item grow>
        {tabIndex === Screen.ControlPanel && (
          <Stack fill vertical g={0}>
            <Stack.Item height={3}>
              <Section>
                <ControlPanel sortByState={sortByState} />
              </Section>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item grow={4}>
              <Section fill scrollable>
                <ApcControlScene sortByState={sortByState} />
              </Section>
            </Stack.Item>
          </Stack>
        )}
        {tabIndex === Screen.LogView && (
          <Section scrollable>
            <Box height={34}>
              <LogPanel />
            </Box>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
}

type ControlProps = {
  sortByState: [string, (field: string) => void];
};

function ControlPanel(props: ControlProps) {
  const { act, data } = useBackend<Data>();
  const { emagged, logging } = data;
  const [sortByField, setSortByField] = props.sortByState;

  return (
    <Stack justify="space-between">
      <Stack.Item>
        <Box inline mr={2} color="label">
          Sort by:
        </Box>
        <Button.Checkbox
          checked={sortByField === 'name'}
          onClick={() => setSortByField('name')}
        >
          Name
        </Button.Checkbox>
        <Button.Checkbox
          checked={sortByField === 'charge'}
          onClick={() => setSortByField('charge')}
        >
          Charge
        </Button.Checkbox>
        <Button.Checkbox
          checked={sortByField === 'draw'}
          onClick={() => setSortByField('draw')}
        >
          Draw
        </Button.Checkbox>
      </Stack.Item>
      <Stack.Item />
      <Stack.Item>
        {!!emagged && (
          <>
            <Button
              color={logging ? 'bad' : 'good'}
              onClick={() => act('toggle-logs')}
            >
              {logging ? 'Stop Logging' : 'Restore Logging'}
            </Button>
            <Button onClick={() => act('restore-console')}>
              Reset Console
            </Button>
          </>
        )}
        <Button icon="sign-out-alt" color="bad" onClick={() => act('log-out')}>
          Log Out
        </Button>
      </Stack.Item>
    </Stack>
  );
}

type WithIndex = APC & { id: string };

function ApcControlScene(props) {
  const { data, act } = useBackend<Data>();

  const [sortByField] = props.sortByState;

  const withIndex = data.apcs.map((apc, idx) => ({
    ...apc,
    id: apc.name + idx,
  }));

  let sorted: WithIndex[] = [];
  if (sortByField === 'name') {
    sorted = sortBy(withIndex, (apc) => apc.name);
  } else if (sortByField === 'charge') {
    sorted = sortBy(withIndex, (apc) => -apc.charge);
  } else if (sortByField === 'draw') {
    sorted = sortBy(
      withIndex,
      (apc) => -powerRank(apc.load),
      (apc) => -parseFloat(apc.load),
    );
  }

  return (
    <Table>
      <Table.Row header>
        <Table.Cell>On/Off</Table.Cell>
        <Table.Cell>Area</Table.Cell>
        <Table.Cell collapsing>Charge</Table.Cell>
        <Table.Cell collapsing textAlign="right">
          Draw
        </Table.Cell>
        <Table.Cell collapsing>Eqp</Table.Cell>
        <Table.Cell collapsing>Lgt</Table.Cell>
        <Table.Cell collapsing>Env</Table.Cell>
      </Table.Row>
      {sorted.map((apc, i) => (
        <Table.Row key={apc.id} className="candystripe">
          <Table.Cell>
            <Button
              icon={apc.operating ? 'power-off' : 'times'}
              color={apc.operating ? 'good' : 'bad'}
              onClick={() =>
                act('breaker', {
                  ref: apc.ref,
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              color="transparent"
              onClick={() =>
                act('access-apc', {
                  ref: apc.ref,
                })
              }
            >
              {apc.name}
            </Button>
          </Table.Cell>
          <Table.Cell className="text-right text-nowrap">
            <AreaCharge charging={apc.charging} charge={apc.charge} />
          </Table.Cell>
          <Table.Cell className="text-right text-nowrap">{apc.load}</Table.Cell>
          <Table.Cell className="text-center text-nowrap">
            <AreaStatusColorButton
              target="equipment"
              status={apc.eqp}
              apc={apc}
              act={act}
            />
          </Table.Cell>
          <Table.Cell className="text-center text-nowrap">
            <AreaStatusColorButton
              target="lighting"
              status={apc.lgt}
              apc={apc}
              act={act}
            />
          </Table.Cell>
          <Table.Cell className="text-center text-nowrap">
            <AreaStatusColorButton
              target="environ"
              status={apc.env}
              apc={apc}
              act={act}
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}

function LogPanel(props) {
  const { data } = useBackend<Data>();

  const logs = data.logs
    .map((line, idx) => ({ ...line, id: line.entry + idx }))
    .reverse();

  return (
    <Box m={-0.5}>
      {logs.map((line) => {
        const colonIndex = line.entry.lastIndexOf(':');
        const timestamp = line.entry.substring(0, colonIndex);
        const message = line.entry.substring(colonIndex + 1);

        return (
          <Box p={0.5} key={line.id} className="candystripe">
            <Box as="b" color="label">
              {timestamp}:
            </Box>{' '}
            <Box>{message}</Box>
          </Box>
        );
      })}
    </Box>
  );
}

function AreaStatusColorButton(props) {
  const { target, status, apc, act } = props;
  const power = Boolean(status & 2);
  const mode = Boolean(status & 1);

  return (
    <Button
      icon={mode ? 'sync' : 'power-off'}
      color={power ? 'good' : 'bad'}
      onClick={() =>
        act('toggle-minor', {
          type: target,
          value: statusChange(status),
          ref: apc.ref,
        })
      }
    />
  );
}

function statusChange(status) {
  // mode flip power flip both flip
  // 0, 2, 3
  return status === 0 ? 2 : status === 2 ? 3 : 0;
}

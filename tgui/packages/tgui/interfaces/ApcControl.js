import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { pureComponentHooks } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Flex, Icon, Table, Tabs } from '../components';
import { Fragment, Window } from '../layouts';
import { AreaCharge, powerRank } from './PowerMonitor';

export const ApcControl = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Window resizable>
      {data.authenticated === 1
      && <ApcLoggedIn />}
      {data.authenticated === 0
      && <ApcLoggedOut />}
    </Window>
  );
};

const ApcLoggedOut = (props, context) => {
  const { act, data } = useBackend(context);
  const { emagged } = data;
  const text = emagged === 1 ? 'Open' : 'Log In';
  return (
    <Window.Content>
      <Button
        fluid
        color={emagged === 1 ? '' : 'good'}
        content={text}
        onClick={() => act('log-in')} />
    </Window.Content>
  );
};

const ApcLoggedIn = (props, context) => {
  const { act, data } = useBackend(context);
  const { restoring } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 1);
  return (
    <Fragment>
      <Tabs>
        <Tabs.Tab
          selected={tabIndex === 1}
          onClick={() => {
            setTabIndex(1);
            act('check-apcs');
          }}>
          APC Control Panel
        </Tabs.Tab>
        <Tabs.Tab
          selected={tabIndex === 2}
          onClick={() => {
            setTabIndex(2);
            act('check-logs');
          }}>
          Log View Panel
        </Tabs.Tab>
      </Tabs>
      {restoring === 1 && (
        <Dimmer fontSize="32px">
          <Icon name="cog" spin />
          {' Resetting...'}
        </Dimmer>
      )}
      {tabIndex === 1 && (
        <Fragment>
          <ControlPanel />
          <Box fillPositionedParent top="53px">
            <Window.Content scrollable>
              <ApcControlScene />
            </Window.Content>
          </Box>
        </Fragment>
      )}
      {tabIndex === 2 && (
        <Box fillPositionedParent top="20px">
          <Window.Content scrollable>
            <LogPanel />
          </Window.Content>
        </Box>
      )}
    </Fragment>
  );
};

const ControlPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    emagged,
    logging,
  } = data;
  const [
    sortByField,
    setSortByField,
  ] = useLocalState(context, 'sortByField', null);
  return (
    <Flex>
      <Flex.Item>
        <Box inline mr={2} color="label">
          Sort by:
        </Box>
        <Button.Checkbox
          checked={sortByField === 'name'}
          content="Name"
          onClick={() => setSortByField(sortByField !== 'name' && 'name')} />
        <Button.Checkbox
          checked={sortByField === 'charge'}
          content="Charge"
          onClick={() => setSortByField(
            sortByField !== 'charge' && 'charge'
          )} />
        <Button.Checkbox
          checked={sortByField === 'draw'}
          content="Draw"
          onClick={() => setSortByField(sortByField !== 'draw' && 'draw')} />
      </Flex.Item>
      <Flex.Item grow={1} />
      <Flex.Item>
        {emagged === 1 && (
          <Fragment>
            <Button
              color={logging === 1 ? 'bad' : 'good'}
              content={logging === 1 ? 'Stop Logging' : 'Restore Logging'}
              onClick={() => act('toggle-logs')}
            />
            <Button
              content="Reset Console"
              onClick={() => act('restore-console')}
            />
          </Fragment>
        )}
        <Button
          color="bad"
          content="Log Out"
          onClick={() => act('log-out')}
        />
      </Flex.Item>
    </Flex>
  );
};

const ApcControlScene = (props, context) => {
  const { data, act } = useBackend(context);

  const [
    sortByField,
  ] = useLocalState(context, 'sortByField', null);

  const apcs = flow([
    map((apc, i) => ({
      ...apc,
      // Generate a unique id
      id: apc.name + i,
    })),
    sortByField === 'name' && sortBy(apc => apc.name),
    sortByField === 'charge' && sortBy(apc => -apc.charge),
    sortByField === 'draw' && sortBy(
      apc => -powerRank(apc.load),
      apc => -parseFloat(apc.load)),
  ])(data.apcs);
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>
          On/Off
        </Table.Cell>
        <Table.Cell>
          Area
        </Table.Cell>
        <Table.Cell collapsing>
          Charge
        </Table.Cell>
        <Table.Cell collapsing textAlign="right">
          Draw
        </Table.Cell>
        <Table.Cell collapsing title="Equipment">
          Eqp
        </Table.Cell>
        <Table.Cell collapsing title="Lighting">
          Lgt
        </Table.Cell>
        <Table.Cell collapsing title="Environment">
          Env
        </Table.Cell>
      </Table.Row>
      {apcs.map((apc, i) => (
        <tr
          key={apc.id}
          className="Table__row  candystripe">
          <td>
            <Button
              icon={apc.operating ? 'power-off' : 'times'}
              color={apc.operating ? 'good' : 'bad'}
              onClick={() => act('breaker', {
                ref: apc.ref,
              })}
            />
          </td>
          <td>
            <Button
              onClick={() => act('access-apc', {
                ref: apc.ref,
              })}>
              {apc.name}
            </Button>
          </td>
          <td className="Table__cell text-right text-nowrap">
            <AreaCharge
              charging={apc.charging}
              charge={apc.charge}
            />
          </td>
          <td className="Table__cell text-right text-nowrap">
            {apc.load}
          </td>
          <td className="Table__cell text-center text-nowrap">
            <AreaStatusColorButton
              target="equipment"
              status={apc.eqp}
              apc={apc}
              act={act}
            />
          </td>
          <td className="Table__cell text-center text-nowrap">
            <AreaStatusColorButton
              target="lighting"
              status={apc.lgt}
              apc={apc}
              act={act}
            />
          </td>
          <td className="Table__cell text-center text-nowrap">
            <AreaStatusColorButton
              target="environ"
              status={apc.env}
              apc={apc}
              act={act}
            />
          </td>
        </tr>
      ))}
    </Table>
  );
};

const LogPanel = (props, context) => {
  const { data } = useBackend(context);

  const logs = flow([
    map((line, i) => ({
      ...line,
      // Generate a unique id
      id: line.entry + i,
    })),
    logs => logs.reverse(),
  ])(data.logs);
  return (
    <Box m={-0.5}>
      {logs.map(line => (
        <Box
          p={0.5}
          key={line.id}
          className="candystripe"
          bold>
          {line.entry}
        </Box>
      ))}
    </Box>
  );
};

const AreaStatusColorButton = props => {
  const { target, status, apc, act } = props;
  const power = Boolean(status & 2);
  const mode = Boolean(status & 1);
  return (
    <Button
      icon={mode ? 'sync' : 'power-off'}
      color={power ? 'good' : 'bad'}
      onClick={() => act('toggle-minor', {
        type: target,
        value: statusChange(status),
        ref: apc.ref,
      })}
    />
  );
};

const statusChange = status => {
  // mode flip power flip both flip
  // 0, 2, 3
  return status === 0 ? 2 : status === 2 ? 3 : 0;
};

AreaStatusColorButton.defaultHooks = pureComponentHooks;


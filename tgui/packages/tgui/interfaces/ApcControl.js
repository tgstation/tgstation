import { Box, Section, Button, Table, Icon, Flex, Tabs } from '../components';
import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { Window, Fragment } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { pureComponentHooks } from 'common/react';

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
  const emagged = data.emagged;
  return (
    <Window.Content>
      <Button
        fluid
        color={'good'}
        tooltip={emagged ? 'Open' : 'Log In'}
        onClick={() => act('log-in')}>
        Log In
      </Button>
    </Window.Content>
  );
};

const ApcLoggedIn = (props, context) => {
  const { act } = useBackend(context);
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
            act("check-apcs");
          }}>
          APC Control Panel
        </Tabs.Tab>
        <Tabs.Tab
          selected={tabIndex === 2}
          onClick={() => {
            setTabIndex(2);
            act("check-logs");
          }}>
          Log View Panel
        </Tabs.Tab>
      </Tabs>
      {tabIndex === 1 && (
        <Fragment>
          <ControlPanel />
          <div className="PowerWindowHeader">
            <Window.Content scrollable>
              <ApcControlScene />
            </Window.Content>
          </div>
        </Fragment>
      )}
      {tabIndex === 2 && (
        <div className="LogWindowTab">
          <Window.Content scrollable>
            <LogPanel />
          </Window.Content>
        </div>
      )}
    </Fragment>
  );
};

const powerRank = str => {
  const unit = String(str.split(' ')[1]).toLowerCase();
  return ['w', 'kw', 'mw', 'gw'].indexOf(unit);
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
      {apcs.map((apc, i) => (
        <Table.Row header
          key={apc.id}
          className="Table__row candystripe">
          <Table.Cell>
            <Button
              icon={apc.operating ? 'power-off' : 'times'}
              color={apc.operating ? 'good' : 'bad'}
              tooltip={apc.operating ? 'On' : 'Off'}
              onClick={() => act('breaker',
                { ref: apc.ref }
              )}
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              onClick={() => act('access-apc',
                { ref: apc.ref }
              )}>
              {apc.name}
            </Button>
          </Table.Cell>
          <Table.Cell collapsing>
            <AreaCharge
              charging={apc.charging}
              charge={apc.charge}
            />
          </Table.Cell>
          <Table.Cell textAlign="right">
            {apc.load}
          </Table.Cell>
          <Table.Cell>
            <AreaStatusColorBox
              target={"equipment"}
              status={apc.eqp}
              apc={apc}
              act={act}
            />
          </Table.Cell>
          <Table.Cell>
            <AreaStatusColorBox
              target={"lighting"}
              status={apc.lgt}
              apc={apc}
              act={act}
            />
          </Table.Cell>
          <Table.Cell>
            <AreaStatusColorBox
              target={"environ"}
              status={apc.env}
              apc={apc}
              act={act}
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const ControlPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const emagged = data.emagged;
  const logging = data.logging;
  const [
    sortByField,
    setSortByField,
  ] = useLocalState(context, 'sortByField', null);
  return (
    <Section>
      <Box mb={1}>
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
        <Button color={(logging === 1 ? "bad" : "good")}
          content={emagged
            && (logging === 1 ? "Stop Logging" : "Restore Logging")}
          onClick={() => act('toggle-logs')}
          right={14}
          position="fixed"
        />
        <Button content={emagged && ("Reset Console")}
          onClick={() => act('restore-console')}
          right={5}
          position="fixed"
        />
        <Button color={'bad'}
          right={0}
          position="fixed"
          tooltip={'Log Out'}
          onClick={() => act('log-out')}>
          Log Out
        </Button>
      </Box>
      <Table.Row header>
        <Table.Cell>
          Area
        </Table.Cell>
        <Table.Cell collapsing>
          Charge
        </Table.Cell>
        <Table.Cell textAlign="right">
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
    </Section>
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
  ])(data.logs.reverse());
  return (
    <Table>
      {logs.map((line, i) => (
        <Table.Row header
          key={line.id}
          className="Table__row candystripe">
          <Table.Cell>
            {line.entry}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
const AreaCharge = props => {
  const { charging, charge } = props;
  return (
    <Fragment>
      <Icon
        width="18px"
        textAlign="center"
        name={(
          charging === 0 && (
            charge > 50
              ? 'battery-half'
              : 'battery-quarter'
          )
          || charging === 1 && 'bolt'
          || charging === 2 && 'battery-full'
        )}
        color={(
          charging === 0 && (
            charge > 50
              ? 'yellow'
              : 'red'
          )
          || charging === 1 && 'yellow'
          || charging === 2 && 'green'
        )} />
      <Box
        inline
        width="36px"
        textAlign="right">
        { toFixed(charge) + '%'}
      </Box>
    </Fragment>
  );
};

AreaCharge.defaultHooks = pureComponentHooks;

const AreaStatusColorBox = props => {
  const { target, status, apc, act } = props;
  const power = Boolean(status & 2);
  const mode = Boolean(status & 1);
  const tooltipText = (power ? 'On' : 'Off')
    + ` [${mode ? 'auto' : 'manual'}]`;
  return (
    <Button
      icon={mode ? 'sync' : 'power-off'}
      color={power ? 'good' : 'bad'}
      tooltip={tooltipText}
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
  return (status == 0) ? 2 : (status == 2) ? 3 : 0;
};

AreaStatusColorBox.defaultHooks = pureComponentHooks;


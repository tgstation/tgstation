import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, Section, Table, Tabs } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const Cargo = (props, context) => {
  return (
    <Window
      width={780}
      height={750}>
      <Window.Content scrollable>
        <CargoContent />
      </Window.Content>
    </Window>
  );
};

export const CargoContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'catalog');
  const {
    requestonly,
  } = data;
  const cart = data.cart || [];
  const requests = data.requests || [];
  return (
    <Box>
      <CargoStatus />
      <Section fitted>
        <Tabs>
          <Tabs.Tab
            icon="list"
            selected={tab === 'catalog'}
            onClick={() => setTab('catalog')}>
            Catalog
          </Tabs.Tab>
          <Tabs.Tab
            icon="envelope"
            textColor={tab !== 'requests'
              && requests.length > 0
              && 'yellow'}
            selected={tab === 'requests'}
            onClick={() => setTab('requests')}>
            Requests ({requests.length})
          </Tabs.Tab>
          {!requestonly && (
            <Tabs.Tab
              icon="shopping-cart"
              textColor={tab !== 'cart'
                && cart.length > 0
                && 'yellow'}
              selected={tab === 'cart'}
              onClick={() => setTab('cart')}>
              Checkout ({cart.length})
            </Tabs.Tab>
          )}
        </Tabs>
      </Section>
      {tab === 'catalog' && (
        <CargoCatalog />
      )}
      {tab === 'requests' && (
        <CargoRequests />
      )}
      {tab === 'cart' && (
        <CargoCart />
      )}
    </Box>
  );
};

const CargoStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    grocery,
    away,
    docked,
    loan,
    loan_dispatched,
    location,
    message,
    points,
    requestonly,
    can_send,
  } = data;
  return (
    <Section
      title="Cargo"
      buttons={(
        <Box inline bold>
          <AnimatedNumber
            value={points}
            format={value => formatMoney(value)} />
          {' credits'}
        </Box>
      )}>
      <LabeledList>
        <LabeledList.Item label="Shuttle">
          {docked && !requestonly && can_send &&(
            <Button
              color={grocery && "orange" || "green"}
              content={location}
              tooltip={grocery && "The chef is waiting on their grocery supplies." || ""}
              tooltipPosition="right"
              onClick={() => act('send')} />
          ) || location}
        </LabeledList.Item>
        <LabeledList.Item label="CentCom Message">
          {message}
        </LabeledList.Item>
        {!!loan && !requestonly && (
          <LabeledList.Item label="Loan">
            {!loan_dispatched && (
              <Button
                content="Loan Shuttle"
                disabled={!(away && docked)}
                onClick={() => act('loan')} />
            ) || (
              <Box color="bad">
                Loaned to Centcom
              </Box>
            )}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const CargoCatalog = (props, context) => {
  const { express } = props;
  const { act, data } = useBackend(context);
  const {
    self_paid,
    app_cost,
  } = data;
  const supplies = Object.values(data.supplies);
  const [
    activeSupplyName,
    setActiveSupplyName,
  ] = useSharedState(context, 'supply', supplies[0]?.name);
  const activeSupply = supplies.find(supply => {
    return supply.name === activeSupplyName;
  });
  return (
    <Section
      title="Catalog"
      buttons={!express && (
        <>
          <CargoCartButtons />
          <Button.Checkbox
            ml={2}
            content="Buy Privately"
            checked={self_paid}
            onClick={() => act('toggleprivate')} />
        </>
      )}>
      <Flex>
        <Flex.Item ml={-1} mr={1}>
          <Tabs vertical>
            {supplies.map(supply => (
              <Tabs.Tab
                key={supply.name}
                selected={supply.name === activeSupplyName}
                onClick={() => setActiveSupplyName(supply.name)}>
                {supply.name} ({supply.packs.length})
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          <Table>
            {activeSupply?.packs.map(pack => {
              const tags = [];
              if (pack.small_item) {
                tags.push('Small');
              }
              if (pack.access) {
                tags.push('Restricted');
              }
              return (
                <Table.Row
                  key={pack.name}
                  className="candystripe">
                  <Table.Cell>
                    {pack.name}
                  </Table.Cell>
                  <Table.Cell
                    collapsing
                    color="label"
                    textAlign="right">
                    {tags.join(', ')}
                  </Table.Cell>
                  <Table.Cell
                    collapsing
                    textAlign="right">
                    <Button
                      fluid
                      tooltip={pack.desc}
                      tooltipPosition="left"
                      onClick={() => act('add', {
                        id: pack.id,
                      })}>
                      {formatMoney((self_paid && !pack.goody) || app_cost
                        ? Math.round(pack.cost * 1.1)
                        : pack.cost)}
                      {' cr'}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const CargoRequests = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    requestonly,
    can_send,
    can_approve_requests,
  } = data;
  const requests = data.requests || [];
  // Labeled list reimplementation to squeeze extra columns out of it
  return (
    <Section
      title="Active Requests"
      buttons={!requestonly && (
        <Button
          icon="times"
          content="Clear"
          color="transparent"
          onClick={() => act('denyall')} />
      )}>
      {requests.length === 0 && (
        <Box color="good">
          No Requests
        </Box>
      )}
      {requests.length > 0 && (
        <Table>
          {requests.map(request => (
            <Table.Row
              key={request.id}
              className="candystripe">
              <Table.Cell collapsing color="label">
                #{request.id}
              </Table.Cell>
              <Table.Cell>
                {request.object}
              </Table.Cell>
              <Table.Cell>
                <b>{request.orderer}</b>
              </Table.Cell>
              <Table.Cell width="25%">
                <i>{request.reason}</i>
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {formatMoney(request.cost)} cr
              </Table.Cell>
              {(!requestonly || can_send)&& can_approve_requests &&(
                <Table.Cell collapsing>
                  <Button
                    icon="check"
                    color="good"
                    onClick={() => act('approve', {
                      id: request.id,
                    })} />
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() => act('deny', {
                      id: request.id,
                    })} />
                </Table.Cell>
              )}
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const CargoCartButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    requestonly,
    can_send,
    can_approve_requests,
  } = data;
  const cart = data.cart || [];
  const total = cart.reduce((total, entry) => total + entry.cost, 0);
  if (requestonly || !can_send || !can_approve_requests) {
    return null;
  }
  return (
    <>
      <Box inline mx={1}>
        {cart.length === 0 && 'Cart is empty'}
        {cart.length === 1 && '1 item'}
        {cart.length >= 2 && cart.length + ' items'}
        {' '}
        {total > 0 && `(${formatMoney(total)} cr)`}
      </Box>
      <Button
        icon="times"
        color="transparent"
        content="Clear"
        onClick={() => act('clear')} />
    </>
  );
};

const CargoCart = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    requestonly,
    away,
    docked,
    location,
    can_send,
  } = data;
  const cart = data.cart || [];
  return (
    <Section
      title="Current Cart"
      buttons={(
        <CargoCartButtons />
      )}>
      {cart.length === 0 && (
        <Box color="label">
          Nothing in cart
        </Box>
      )}
      {cart.length > 0 && (
        <Table>
          {cart.map(entry => (
            <Table.Row
              key={entry.id}
              className="candystripe">
              <Table.Cell collapsing color="label">
                #{entry.id}
              </Table.Cell>
              <Table.Cell>
                {entry.object}
              </Table.Cell>
              <Table.Cell collapsing>
                {!!entry.paid && (
                  <b>[Paid Privately]</b>
                )}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {formatMoney(entry.cost)} cr
              </Table.Cell>
              <Table.Cell collapsing>
                {can_send &&(
                  <Button
                    icon="minus"
                    onClick={() => act('remove', {
                      id: entry.id,
                    })} />
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
      {cart.length > 0 && !requestonly && (
        <Box mt={2}>
          {away === 1 && docked === 1 && (
            <Button
              color="green"
              style={{
                'line-height': '28px',
                'padding': '0 12px',
              }}
              content="Confirm the order"
              onClick={() => act('send')} />
          ) || (
            <Box opacity={0.5}>
              Shuttle in {location}.
            </Box>
          )}
        </Box>
      )}
    </Section>
  );
};

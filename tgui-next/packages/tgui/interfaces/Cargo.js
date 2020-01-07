import { map } from 'common/collections';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, LabeledList, Section, Tabs } from '../components';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const Cargo = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const supplies = data.supplies || {};
  const requests = data.requests || [];
  const cart = data.cart || [];

  const cartTotalAmount = cart
    .reduce((total, entry) => total + entry.cost, 0);

  const cartButtons = !data.requestonly && (
    <Fragment>
      <Box inline mx={1}>
        {cart.length === 0 && 'Cart is empty'}
        {cart.length === 1 && '1 item'}
        {cart.length >= 2 && cart.length + ' items'}
        {' '}
        {cartTotalAmount > 0 && `(${cartTotalAmount} cr)`}
      </Box>
      <Button
        icon="times"
        color="transparent"
        content="Clear"
        onClick={() => act(ref, 'clear')} />
    </Fragment>
  );

  return (
    <Fragment>
      <Section
        title="Cargo"
        buttons={(
          <Box inline bold>
            <AnimatedNumber value={Math.round(data.points)} /> credits
          </Box>
        )}>
        <LabeledList>
          <LabeledList.Item label="Shuttle">
            {data.docked && !data.requestonly && (
              <Button
                content={data.location}
                onClick={() => act(ref, 'send')} />
            ) || data.location}
          </LabeledList.Item>
          <LabeledList.Item label="CentCom Message">
            {data.message}
          </LabeledList.Item>
          {(data.loan && !data.requestonly) ? (
            <LabeledList.Item label="Loan">
              {!data.loan_dispatched ? (
                <Button
                  content="Loan Shuttle"
                  disabled={!(data.away && data.docked)}
                  onClick={() => act(ref, 'loan')} />
              ) : (
                <Box color="bad">Loaned to Centcom</Box>
              )}
            </LabeledList.Item>
          ) : ''}
        </LabeledList>
      </Section>
      <Tabs mt={2}>
        <Tabs.Tab
          key="catalog"
          label="Catalog"
          icon="list"
          lineHeight="23px">
          {() => (
            <Section
              title="Catalog"
              buttons={(
                <Fragment>
                  {cartButtons}
                  <Button
                    ml={1}
                    icon={data.self_paid ? 'check-square-o' : 'square-o'}
                    content="Buy Privately"
                    selected={data.self_paid}
                    onClick={() => act(ref, 'toggleprivate')} />
                </Fragment>
              )}>
              <Catalog state={state} supplies={supplies} />
            </Section>
          )}
        </Tabs.Tab>
        <Tabs.Tab
          key="requests"
          label={`Requests (${requests.length})`}
          icon="envelope"
          highlight={requests.length > 0}
          lineHeight="23px">
          {() => (
            <Section
              title="Active Requests"
              buttons={!data.requestonly && (
                <Button
                  icon="times"
                  content="Clear"
                  color="transparent"
                  onClick={() => act(ref, 'denyall')} />
              )}>
              <Requests state={state} requests={requests} />
            </Section>
          )}
        </Tabs.Tab>
        {!data.requestonly && (
          <Tabs.Tab
            key="cart"
            label={`Checkout (${cart.length})`}
            icon="shopping-cart"
            highlight={cart.length > 0}
            lineHeight="23px">
            {() => (
              <Section
                title="Current Cart"
                buttons={cartButtons}>
                <Cart state={state} cart={cart} />
              </Section>
            )}
          </Tabs.Tab>
        )}
      </Tabs>
    </Fragment>
  );
};

const Catalog = props => {
  const { state, supplies } = props;
  const { config, data } = state;
  const { ref } = config;
  const renderTab = key => {
    const supply = supplies[key];
    const packs = supply.packs;
    return (
      <table className="LabeledList">
        {packs.map(pack => (
          <tr
            key={pack.name}
            className="LabeledList__row candystripe">
            <td className="LabeledList__cell LabeledList__label">
              {pack.name}:
            </td>
            <td className="LabeledList__cell">
              {!!pack.small_item && (
                <Fragment>Small Item</Fragment>
              )}
            </td>
            <td className="LabeledList__cell">
              {!!pack.access && (
                <Fragment>Restrictions Apply</Fragment>
              )}
            </td>
            <td className="LabeledList__cell LabeledList__buttons">
              <Button fluid
                content={(data.self_paid
                  ? Math.round(pack.cost * 1.1)
                  : pack.cost) + ' credits'}
                tooltip={pack.desc}
                tooltipPosition="left"
                onClick={() => act(ref, 'add', {
                  id: pack.id,
                })} />
            </td>
          </tr>
        ))}
      </table>
    );
  };
  return (
    <Tabs vertical>
      {map(supply => {
        const name = supply.name;
        return (
          <Tabs.Tab key={name} label={name}>
            {renderTab}
          </Tabs.Tab>
        );
      })(supplies)}
    </Tabs>
  );
};

const Requests = props => {
  const { state, requests } = props;
  const { config, data } = state;
  const { ref } = config;
  if (requests.length === 0) {
    return (
      <Box color="good">
        No Requests
      </Box>
    );
  }
  // Labeled list reimplementation to squeeze extra columns out of it
  return (
    <table className="LabeledList">
      {requests.map(request => (
        <Fragment key={request.id}>
          <tr className="LabeledList__row candystripe">
            <td className="LabeledList__cell LabeledList__label">
              #{request.id}:
            </td>
            <td className="LabeledList__cell LabeledList__content">
              {request.object}
            </td>
            <td className="LabeledList__cell">
              By <b>{request.orderer}</b>
            </td>
            <td className="LabeledList__cell">
              <i>{request.reason}</i>
            </td>
            <td className="LabeledList__cell LabeledList__buttons">
              {request.cost} credits
              {' '}
              {!data.requestonly && (
                <Fragment>
                  <Button
                    icon="check"
                    color="good"
                    onClick={() => act(ref, 'approve', {
                      id: request.id,
                    })} />
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() => act(ref, 'deny', {
                      id: request.id,
                    })} />
                </Fragment>
              )}
            </td>
          </tr>
        </Fragment>
      ))}
    </table>
  );
};

const Cart = props => {
  const { state, cart } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      {cart.length === 0 && 'Nothing in cart'}
      {cart.length > 0 && (
        <LabeledList>
          {cart.map(entry => (
            <LabeledList.Item
              key={entry.id}
              className="candystripe"
              label={'#' + entry.id}
              buttons={(
                <Fragment>
                  <Box inline mx={2}>
                    {!!entry.paid && (<b>[Paid Privately]</b>)}
                    {' '}
                    {entry.cost} credits
                  </Box>
                  <Button
                    icon="minus"
                    onClick={() => act(ref, 'remove', {
                      id: entry.id,
                    })} />
                </Fragment>
              )}>
              {entry.object}
            </LabeledList.Item>
          ))}
        </LabeledList>
      )}
      {cart.length > 0 && !data.requestonly && (
        <Box mt={2}>
          {data.away === 1 && data.docked === 1 && (
            <Button
              color="green"
              style={{
                'line-height': '28px',
                'padding': '0 12px',
              }}
              content="Confirm the order"
              onClick={() => act(ref, 'send')} />
          ) || (
            <Box opacity={0.5}>
              Shuttle in {data.location}.
            </Box>
          )}
        </Box>
      )}
    </Fragment>
  );
};

export const CargoExpress = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const supplies = data.supplies || {};
  return (
    <Fragment>
      <InterfaceLockNoticeBox
        siliconUser={data.siliconUser}
        locked={data.locked}
        onLockStatusChange={() => act(ref, 'lock')}
        accessText="a QM-level ID card" />
      {!data.locked &&(
        <Fragment>
          <Section
            title="Cargo Express"
            buttons={(
              <Box inline bold>
                <AnimatedNumber value={Math.round(data.points)} /> credits
              </Box>
            )}>
            <LabeledList>
              <LabeledList.Item label="Landing Location">
                <Button
                  content="Cargo Bay"
                  selected={!data.usingBeacon}
                  onClick={() => act(ref, 'LZCargo')} />
                <Button
                  selected={data.usingBeacon}
                  disabled={!data.hasBeacon}
                  onClick={() => act(ref, 'LZBeacon')}>
                  {data.beaconzone} ({data.beaconName})
                </Button>
                <Button
                  content={data.printMsg}
                  disabled={!data.canBuyBeacon}
                  onClick={() => act(ref, 'printBeacon')} />
              </LabeledList.Item>
              <LabeledList.Item label="Notice">
                {data.message}
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Catalog state={state} supplies={supplies} />
        </Fragment>
      )}
    </Fragment>
  );
};

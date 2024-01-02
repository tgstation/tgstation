import { CargoCatalog } from '../../tgui/interfaces/Cargo.js';
import { useBackend, useSharedState } from '../../tgui/backend';
import { AnimatedNumber, Box, Button, Input, RestrictedInput, LabeledList, Section, Stack, Table, Tabs } from '../../tgui/components';
import { formatMoney } from '../../tgui/format';
import { Window } from '../../tgui/layouts';

export const VoidcrewCargo = (props, context) => {
  return (
    <Window width={800} height={750}>
      <Window.Content scrollable>
        <VoidcrewCargoContent />
      </Window.Content>
    </Window>
  );
};

export const VoidcrewCargoContent = (props, context) => {
  const { data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'catalog');
  const { cart = [] } = data;
  const cart_length = cart.reduce((total, entry) => total + entry.amount, 0);
  return (
    <Box>
      <VoidcrewCargoStatus />
      <Section fitted>
        <Tabs>
          <Tabs.Tab
            icon="list"
            selected={tab === 'catalog'}
            onClick={() => setTab('catalog')}>
            Catalog
          </Tabs.Tab>
          <Tabs.Tab
            icon="shopping-cart"
            textColor={tab !== 'cart' && cart_length > 0 && 'yellow'}
            selected={tab === 'cart'}
            onClick={() => setTab('cart')}>
            Checkout ({cart_length})
          </Tabs.Tab>
        </Tabs>
      </Section>
      {tab === 'catalog' && <CargoCatalog />}
      {tab === 'cart' && <VoidcrewCargoCart />}
    </Box>
  );
};

const VoidcrewCargoStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beacon_cost_message,
    has_beacon,
    can_buy_beacon,
    on_cargo_cooldown,
    cargo_ordered,
    beacon_error_message,
    points,
  } = data;
  return (
    <Section>
      <Box position="absolute" right={1} bold>
        {(points && (
          <>
            <AnimatedNumber
              value={points}
              format={(value) => formatMoney(value)}
            />
            {' credits'}
          </>
        )) || <AnimatedNumber value="No credits" />}
      </Box>
      {!has_beacon && (
        <Button
          content={beacon_cost_message}
          disabled={!can_buy_beacon}
          onClick={() => act('print_beacon')}
        />
      )}
      <LabeledList>
        <LabeledList.Item label="Freight Container">
          <Button
            color={'green'}
            disabled={on_cargo_cooldown}
            tooltip={on_cargo_cooldown ? 'On cooldown' : 'Send freight'}
            content={cargo_ordered ? 'Cargo Bay' : 'Away'}
            onClick={() => act('send')}
          />
        </LabeledList.Item>
        {!!beacon_error_message && (
          <LabeledList.Item label="CentCom Message">
            {beacon_error_message}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const VoidcrewCargoCartButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { cart = [], cargo_ordered } = data;
  const total = cart.reduce((total, entry) => total + entry.cost, 0);
  return (
    <>
      <Box inline mx={1}>
        {cart.length === 0 && 'Cart is empty'}
        {cart.length === 1 && '1 item'}
        {cart.length >= 2 && cart.length + ' items'}{' '}
        {total > 0 && `(${formatMoney(total)} cr)`}
      </Box>
      {!cargo_ordered && (
        <Button
          icon="times"
          color="transparent"
          content="Clear"
          onClick={() => act('clear')}
        />
      )}
    </>
  );
};

const VoidcrewCargoCart = (props, context) => {
  const { act, data } = useBackend(context);
  const { cart = [], cargo_ordered } = data;
  return (
    <Section fill>
      <Section>
        <Stack>
          <Stack.Item mt="4px">Current-Cart</Stack.Item>
          <Stack.Item ml="200px" mt="3px">
            Quantity
          </Stack.Item>
          <Stack.Item ml="72px">
            <VoidcrewCargoCartButtons />
          </Stack.Item>
        </Stack>
      </Section>
      {cart.length === 0 && <Box color="label">Nothing in cart</Box>}
      {cart.length > 0 && (
        <Table>
          {cart.map((entry) => (
            <Table.Row key={entry.id} className="candystripe">
              <Table.Cell collapsing color="label" inline width="210px">
                #{entry.id}&nbsp;{entry.object}
              </Table.Cell>
              <Table.Cell inline ml="65px" width="40px">
                {(!cargo_ordered && entry.can_be_cancelled && (
                  <RestrictedInput
                    width="40px"
                    minValue={0}
                    maxValue={50}
                    value={entry.amount}
                    onEnter={(e, value) =>
                      act('modify', {
                        order_name: entry.object,
                        amount: value,
                      })
                    }
                  />
                )) || <Input width="40px" value={entry.amount} disabled />}
              </Table.Cell>
              <Table.Cell inline ml="5px" width="10px">
                {!cargo_ordered && !!entry.can_be_cancelled && (
                  <Button
                    icon="plus"
                    onClick={() =>
                      act('add_by_name', { order_name: entry.object })
                    }
                  />
                )}
              </Table.Cell>
              <Table.Cell inline ml="15px" width="10px">
                {!cargo_ordered && !!entry.can_be_cancelled && (
                  <Button
                    icon="minus"
                    onClick={() => act('remove', { order_name: entry.object })}
                  />
                )}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right" inline ml="50px">
                {formatMoney(entry.cost)} {entry.cost_type}
              </Table.Cell>
              <Table.Cell inline mt="20px" />
            </Table.Row>
          ))}
        </Table>
      )}
      {cart.length > 0 && (
        <Box mt={2}>
          {(cargo_ordered && (
            <Button
              color="green"
              style={{
                'line-height': '28px',
                'padding': '0 12px',
              }}
              content="Confirm the order"
              onClick={() => act('send')}
            />
          )) || (
            <Box opacity={0.5}>
              Cargo at {cargo_ordered ? 'Cargo Bay' : 'Away'}.
            </Box>
          )}
        </Box>
      )}
    </Section>
  );
};

import { useState } from 'react';
import {
  Button,
  Icon,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import type { CargoData } from './types';

type CargoCartProps = {
  act: any;
} & CargoCartData;

type CargoCartData = Pick<
  CargoData,
  'can_send' | 'away' | 'cart' | 'docked' | 'location' | 'max_order'
>;

export function CargoCart(props: CargoCartProps) {
  const { act, can_send, away, cart = [], docked, location, max_order } = props;

  const sendable = !!away && !!docked;

  return (
    <Stack fill vertical g={0}>
      <Stack.Item grow>
        <Section fill scrollable>
          <CheckoutItems
            act={act}
            max_order={max_order}
            can_send={can_send}
            cart={cart}
          />
        </Section>
      </Stack.Item>
      {cart.length > 0 && !!can_send && (
        <Stack.Item>
          <Section textAlign="right">
            <Stack fill align="center">
              <Stack.Item grow>
                {!sendable && (
                  <Icon mr={0.5} size={1.5} color="blue" name="toolbox" spin />
                )}
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="green"
                  disabled={!sendable}
                  onClick={() => act('send')}
                  px={2}
                  py={1}
                  tooltip={sendable ? '' : `Shuttle is at ${location}`}
                >
                  Confirm the order
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
}

type CheckoutItemsProps = {
  act: any;
} & CheckoutItemsData;

type CheckoutItemsData = Pick<CargoData, 'can_send' | 'cart' | 'max_order'>;

function CheckoutItems(props: CheckoutItemsProps) {
  const { act, can_send, cart = [], max_order } = props;

  const [isValid, setIsValid] = useState(true);

  if (cart.length === 0) {
    return <NoticeBox>Nothing in cart</NoticeBox>;
  }

  return (
    <Table>
      <Table.Row header color="gray">
        <Table.Cell collapsing>ID</Table.Cell>
        <Table.Cell>Supply Type</Table.Cell>
        <Table.Cell>Amount</Table.Cell>
        <Table.Cell collapsing />
        <Table.Cell collapsing textAlign="right">
          Cost
        </Table.Cell>
      </Table.Row>

      {cart.map((entry) => (
        <Table.Row className="candystripe" key={entry.id}>
          <Table.Cell collapsing color="label">
            #{entry.id}
          </Table.Cell>
          <Table.Cell>{entry.object}</Table.Cell>

          <Table.Cell width={11}>
            {can_send && entry.can_be_cancelled ? (
              <>
                <Button
                  icon="minus"
                  onClick={() => act('remove', { order_name: entry.object })}
                />
                <RestrictedInput
                  width={5}
                  minValue={0}
                  maxValue={max_order}
                  value={entry.amount}
                  onEnter={(value) =>
                    isValid &&
                    act('modify', {
                      order_name: entry.object,
                      amount: value,
                    })
                  }
                  onValidationChange={setIsValid}
                />
                <Button
                  icon="plus"
                  disabled={entry.amount >= max_order}
                  onClick={() =>
                    act('add_by_name', { order_name: entry.object })
                  }
                />
              </>
            ) : (
              <RestrictedInput width="40px" value={entry.amount} disabled />
            )}
          </Table.Cell>

          <Table.Cell collapsing color="average">
            {!!entry.paid && <b>[Private x {entry.amount}]</b>}
            {!!entry.dep_order && <b>[Department x {entry.amount}]</b>}
          </Table.Cell>

          <Table.Cell collapsing color="gold" textAlign="right">
            {formatMoney(entry.cost)} {entry.cost_type}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}

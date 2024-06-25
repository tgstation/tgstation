import { useBackend } from '../../backend';
import {
  Button,
  Icon,
  Input,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
} from '../../components';
import { formatMoney } from '../../format';
import { CargoCartButtons } from './CargoButtons';
import { CargoData } from './types';

export function CargoCart(props) {
  const { act, data } = useBackend<CargoData>();
  const { can_send, away, cart = [], docked, location } = data;

  const sendable = !!away && !!docked;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable title="Cart" buttons={<CargoCartButtons />}>
          <CheckoutItems />
        </Section>
      </Stack.Item>
      {cart.length > 0 && !!can_send && (
        <Stack.Item>
          <Section align="right">
            <Stack fill align="center">
              <Stack.Item grow>
                {!sendable && <Icon color="blue" name="toolbox" spin />}
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

function CheckoutItems(props) {
  const { act, data } = useBackend<CargoData>();
  const { amount_by_name = {}, can_send, cart = [], max_order } = data;

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
              <RestrictedInput
                width={5}
                minValue={0}
                maxValue={max_order}
                value={entry.amount}
                onEnter={(e, value) =>
                  act('modify', {
                    order_name: entry.object,
                    amount: value,
                  })
                }
              />
            ) : (
              <Input width="40px" value={entry.amount} disabled />
            )}

            {!!can_send && !!entry.can_be_cancelled && (
              <>
                <Button
                  icon="plus"
                  disabled={amount_by_name[entry.object] >= max_order}
                  onClick={() =>
                    act('add_by_name', { order_name: entry.object })
                  }
                />
                <Button
                  icon="minus"
                  onClick={() => act('remove', { order_name: entry.object })}
                />
              </>
            )}
          </Table.Cell>

          <Table.Cell collapsing color="average">
            {!!entry.paid && <b>[Private x {entry.paid}]</b>}
            {!!entry.dep_order && <b>[Department x {entry.dep_order}]</b>}
          </Table.Cell>

          <Table.Cell collapsing color="gold" textAlign="right">
            {formatMoney(entry.cost)} {entry.cost_type}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}

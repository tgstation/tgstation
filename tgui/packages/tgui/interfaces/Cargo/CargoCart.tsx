import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Input,
  RestrictedInput,
  Section,
  Table,
} from '../../components';
import { formatMoney } from '../../format';
import { CartHeader } from './CargoHeader';
import { CargoData } from './types';

export function CargoCart(props) {
  const { act, data } = useBackend<CargoData>();
  const {
    requestonly,
    away,
    cart = [],
    docked,
    location,
    can_send,
    amount_by_name,
    max_order,
  } = data;

  return (
    <Section fill>
      <CartHeader />
      {cart.length === 0 && <Box color="label">Nothing in cart</Box>}
      {cart.length > 0 && (
        <Table>
          {cart.map((entry) => (
            <Table.Row key={entry.id} className="candystripe">
              <Table.Cell collapsing color="label" inline width="210px">
                #{entry.id}&nbsp;{entry.object}
              </Table.Cell>
              <Table.Cell inline ml="65px" width="40px">
                {can_send && entry.can_be_cancelled ? (
                  <RestrictedInput
                    width="40px"
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
              </Table.Cell>
              <Table.Cell inline ml="5px" width="10px">
                {!!can_send && !!entry.can_be_cancelled && (
                  <Button
                    icon="plus"
                    disabled={amount_by_name[entry.object] >= max_order}
                    onClick={() =>
                      act('add_by_name', { order_name: entry.object })
                    }
                  />
                )}
              </Table.Cell>
              <Table.Cell inline ml="15px" width="10px">
                {!!can_send && !!entry.can_be_cancelled && (
                  <Button
                    icon="minus"
                    onClick={() => act('remove', { order_name: entry.object })}
                  />
                )}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right" inline ml="50px">
                {!!entry.paid && <b>[Paid Privately x {entry.paid}]</b>}
                {formatMoney(entry.cost)} {entry.cost_type}
                {!!entry.dep_order && <b>[Department x {entry.dep_order}]</b>}
              </Table.Cell>
              <Table.Cell inline mt="20px" />
            </Table.Row>
          ))}
        </Table>
      )}
      {cart.length > 0 && !requestonly && (
        <Box mt={2}>
          {!!away && !!docked ? (
            <Button
              color="green"
              style={{
                lineHeight: '28px',
                padding: '0 12px',
              }}
              onClick={() => act('send')}
            >
              Confirm the order
            </Button>
          ) : (
            <Box opacity={0.5}>Shuttle in {location}.</Box>
          )}
        </Box>
      )}
    </Section>
  );
}

import { Box, Button } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import type { CargoData } from './types';

type CargoCartButtonsProps = {
  act: any;
} & CargoCartButtonsData;

type CargoCartButtonsData = Pick<
  CargoData,
  | 'cart'
  | 'requestonly'
  | 'can_send'
  | 'can_approve_requests'
  | 'displayed_currency_name'
>;

export function CargoCartButtons(props: CargoCartButtonsProps) {
  const {
    act,
    cart = [],
    requestonly,
    can_send,
    can_approve_requests,
    displayed_currency_name,
  } = props;

  let total = 0;
  let amount = 0;
  for (let i = 0; i < cart.length; i++) {
    amount += cart[i].amount;
    total += cart[i].cost;
  }

  const canClear =
    !requestonly && !!can_send && !!can_approve_requests && cart.length > 0;

  return (
    <>
      <Box inline mx={1}>
        {amount === 0 && 'Cart is empty'}
        {amount === 1 && '1 item'}
        {amount >= 2 && `${amount} items`}{' '}
        {total > 0 && `(${formatMoney(total)}${displayed_currency_name})`}
      </Box>

      <Button
        disabled={!canClear}
        icon="times"
        color="transparent"
        onClick={() => act('clear')}
      >
        Clear
      </Button>
    </>
  );
}

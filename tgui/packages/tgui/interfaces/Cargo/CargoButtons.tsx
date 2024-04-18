import { useBackend } from '../../backend';
import { Box, Button } from '../../components';
import { formatMoney } from '../../format';
import { CargoData } from './types';

export function CargoCartButtons(props) {
  const { act, data } = useBackend<CargoData>();
  const { cart = [], requestonly, can_send, can_approve_requests } = data;

  const total = cart.reduce((total, entry) => total + entry.cost, 0);

  return (
    <>
      <Box inline mx={1}>
        {cart.length === 0 && 'Cart is empty'}
        {cart.length === 1 && '1 item'}
        {cart.length >= 2 && cart.length + ' items'}{' '}
        {total > 0 && `(${formatMoney(total)} cr)`}
      </Box>
      {!requestonly && !!can_send && !!can_approve_requests && (
        <Button icon="times" color="transparent" onClick={() => act('clear')}>
          Clear
        </Button>
      )}
    </>
  );
}

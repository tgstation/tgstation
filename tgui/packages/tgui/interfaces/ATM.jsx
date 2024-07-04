import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Box, Button, Stack, Section } from '../components';

export const ATM = (props) => {
  const { act, data } = useBackend();

  const {
    flash_sale_present,
    flash_sale_name,
    flash_sale_desc,
    flash_sale_cost,
    meta_balance,
    cash_balance,
    lottery_pool,
  } = data;

  return (
    <Window resizable title="ATM" width={300} height={200}>
      <Section>
        <Stack vertical fill>
          <Section>
            <Stack.Item>
              <Box>Current Account Balance: {cash_balance}</Box>
            </Stack.Item>
            <Stack.Item>
              <Box>
                Current Monkecoin Balance: {meta_balance}{' '}
                <i class="fa-solid fa-coins" />
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box>Current Lottery Prize Pool: {lottery_pool}</Box>
            </Stack.Item>
          </Section>
          <Section>
            <Stack.Item>
              <Button onClick={() => act('withdraw')}>
                Withdraw Monkecoins
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('withdraw_cash')}>
                Withdraw Cash
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('lottery_buy')}>
                Purchase Lottery Tickets
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('buy_lootbox')}>
                Purchase Lootbox
              </Button>
            </Stack.Item>
          </Section>
          {flash_sale_present ? (
            <Section>
              <Stack.Item>
                <Box>Flash Sale!</Box>
              </Stack.Item>
              <Stack.Item>
                <Box>{flash_sale_name}</Box>
              </Stack.Item>
              <Stack.Item>
                <Box>{flash_sale_desc}</Box>
              </Stack.Item>
              <Stack.Item>
                <Box>
                  and this could be yours for the low price of {flash_sale_cost}{' '}
                  Monkecoins!
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button onClick={() => act('buy_flash')}>Buy Now!</Button>
              </Stack.Item>
            </Section>
          ) : (
            ''
          )}
        </Stack>
      </Section>
    </Window>
  );
};

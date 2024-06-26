import { useBackend, useLocalState } from '../backend';
import { Box, Section, Stack, Table, Tabs, Button } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';
import { toFixed } from 'common/math';

export const XenobioMarket = (_) => {
  const [tabIndex, setTabIndex] = useLocalState('tabIndex', 1);
  const { data } = useBackend();
  const { points } = data;

  return (
    <Window width={900} height={(tabIndex === 1 && 412) || 600}>
      <Window.Content>
        <Tabs style={{ 'border-radius': '5px' }}>
          <Tabs.Tab
            key={1}
            selected={tabIndex === 1}
            icon="flask"
            onClick={() => setTabIndex(1)}
          >
            Slime Market
          </Tabs.Tab>
          <Tabs.Tab
            key={2}
            selected={tabIndex === 2}
            icon="flask"
            onClick={() => setTabIndex(2)}
          >
            Active Requests
          </Tabs.Tab>
          <Tabs.Tab
            key={3}
            selected={tabIndex === 3}
            icon="sack-dollar"
            onClick={() => setTabIndex(3)}
          >
            View Shop
          </Tabs.Tab>
          <Button icon={'sack-dollar'} color="green">
            {points}
          </Button>
        </Tabs>
        <Box>{tabIndex === 1 && <SlimeMarket />}</Box>
        <Box>{tabIndex === 2 && <RequestViewer />}</Box>
        <Box>{tabIndex === 3 && <StoreViewer />}</Box>
      </Window.Content>
    </Window>
  );
};

const SlimeMarket = (_) => {
  const { data } = useBackend();
  const { prices } = data;

  return (
    <Table>
      {prices.map((price_row) => (
        <Table.Row key={price_row.key}>
          {price_row.prices.map((slime_price) => (
            <Table.Cell width="25%" key={slime_price.key}>
              {!!slime_price.price && (
                <Section style={{ 'border-radius': '5px' }} mb="6px">
                  <Stack fill>
                    <Stack.Item>
                      <Box
                        className={classes([
                          'xenobio_market32x32',
                          slime_price.icon,
                        ])}
                      />
                    </Stack.Item>
                    <Stack.Item mt="10px">
                      Currect price: {toFixed(slime_price.price, 0)} points.
                    </Stack.Item>
                  </Stack>
                </Section>
              )}
            </Table.Cell>
          ))}
        </Table.Row>
      ))}
    </Table>
  );
};

const RequestViewer = (_) => {
  const { data } = useBackend();
  const { requests } = data;

  return (
    <Table>
      {requests.map((request) => (
        <Section style={{ 'border-radius': '5px' }} mb="6px" key={request.name}>
          <Stack fill>
            <Stack.Item>
              <Box
                style={{
                  transform: 'scale(2)',
                }}
                className={classes(['xenobio_market32x32', request.icon])}
              />
            </Stack.Item>
            <Stack.Item mt="10px">{request.name}</Stack.Item>
            <Stack.Item mt="10px">
              | Payout: {toFixed(request.payout, 0)} credits. | Xenobiology
              Points: {toFixed(request.payout * 3, 0)}
            </Stack.Item>
            <Stack.Item mt="10px">
              | {toFixed(request.amount - request.amount_give, 0)} extracts
              left.
            </Stack.Item>
          </Stack>
        </Section>
      ))}
    </Table>
  );
};

const StoreViewer = (_) => {
  const { data, act } = useBackend();
  const { shop_items } = data;

  return (
    <Table>
      {shop_items.map((item) => (
        <Section style={{ 'border-radius': '5px' }} mb="6px" key={item.name}>
          <Stack fill>
            <Stack.Item>
              <Box
                style={{
                  transform: 'scale(2)',
                }}
                className={classes(['xenobio_market32x32', item.icon_state])}
              />
            </Stack.Item>
            <Stack.Item>
              <Box fontSize="24px">{item.name}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                ml="10px"
                mt="7px"
                icon={'question'}
                tooltip={item.desc}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                ml="5px"
                mt="7px"
                icon={'sack-dollar'}
                color="green"
                onClick={() => act('buy', { path: item.item_path })}
              >
                {item.cost + ' Xenobiology Points'}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      ))}
    </Table>
  );
};

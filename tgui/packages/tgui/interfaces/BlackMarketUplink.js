import { round } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Modal, Section, Stack, Tabs, Slider } from '../components';
import { formatMoney, formatTime } from '../format';
import { Window } from '../layouts';

export const BlackMarketUplink = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories = [],
    markets = [],
    items = [],
    money,
    viewing_market,
    viewing_category,
    auction,
  } = data;
  return (
    <Window width={670} height={480} theme="hackerman">
      <ShipmentSelector />
      <Window.Content scrollable>
        <Box position="relative" height="100%">
          <Section
            title="Black Market Uplink"
            buttons={
              <Box inline bold>
                <AnimatedNumber
                  value={money}
                  format={(value) => formatMoney(value) + ' cr'}
                />
              </Box>
            }
          />
          <Tabs>
            {markets.map((market) => (
              <Tabs.Tab
                key={market.id}
                selected={market.id === viewing_market}
                onClick={() =>
                  act('set_market', {
                    market: market.id,
                  })
                }>
                {market.name}
              </Tabs.Tab>
            ))}
          </Tabs>
          {auction ? <AuctionMarket /> : <NormalMarket />}
        </Box>
      </Window.Content>
    </Window>
  );
};

const ShipmentSelector = (props, context) => {
  const { act, data } = useBackend(context);
  const { buying, ltsrbt_built, money } = data;
  if (!buying) {
    return null;
  }
  const deliveryMethods = data.delivery_methods.map((method) => {
    const description = data.delivery_method_description[method.name];
    return {
      ...method,
      description,
    };
  });
  return (
    <Modal textAlign="center">
      <Stack mb={1}>
        {deliveryMethods.map((method) => {
          if (method.name === 'LTSRBT' && !ltsrbt_built) {
            return null;
          }
          return (
            <Stack.Item key={method.name} mx={1} width="17.5rem">
              <Box fontSize="30px">{method.name}</Box>
              <Box mt={1}>{method.description}</Box>
              <Button
                mt={2}
                content={formatMoney(method.price) + ' cr'}
                disabled={money < method.price}
                onClick={() =>
                  act('buy', {
                    method: method.name,
                  })
                }
              />
            </Stack.Item>
          );
        })}
      </Stack>
      <Button content="Cancel" color="bad" onClick={() => act('cancel')} />
    </Modal>
  );
};

const NormalMarket = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories = [],
    markets = [],
    items = [],
    money,
    viewing_market,
    viewing_category,
    auction,
  } = data;

  return (
    <Stack>
      <Stack.Item>
        <Tabs vertical>
          {categories.map((category) => (
            <Tabs.Tab
              key={category}
              mt={0.5}
              selected={viewing_category === category}
              onClick={() =>
                act('set_category', {
                  category: category,
                })
              }>
              {category}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {items.map((item) => (
          <Box key={item.name} className="candystripe" p={1} pb={2}>
            <Stack align="baseline">
              <Stack.Item grow bold>
                {item.name}
              </Stack.Item>
              <Stack.Item color="label">
                {item.amount ? item.amount + ' in stock' : 'Out of stock'}
              </Stack.Item>
              <Stack.Item color="label">
                {item.time_left ? item.time_left + ' Seconds Left' : ''}
              </Stack.Item>
              <Stack.Item>{formatMoney(item.cost) + ' cr'}</Stack.Item>
              <Stack.Item>
                <Button
                  content="Buy"
                  disabled={!item.amount || item.cost > money}
                  onClick={() =>
                    act('select', {
                      item: item.id,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
            {item.desc}
          </Box>
        ))}
      </Stack.Item>
    </Stack>
  );
};

const AuctionMarket = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories = [],
    items = [],
    money,
    viewing_category,
    bidders = [],
    time_left,
    queued_items = [],
    current_item = [],
    current_bid,
  } = data;

  return (
    <Stack height="79%">
      <Stack.Item width="50%">
        <Stack vertical fill>
          <Stack.Item grow={1}>
            <Section bold fontSize="16px" textAlign="center" grow>
              {current_item.name ? current_item.name : 'No Auction'}
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Stack width="100%" height="20%">
              <Stack.Item width="70%">
                <Box fontSize="16px" className="candystripe">
                  {current_item.top_bidder
                    ? current_item.top_bidder
                    : 'No Bidder'}
                </Box>
              </Stack.Item>
              <Stack.Item width="30%" textAlign="center">
                <Box backgroundColor="green" fontSize="16px">
                  {current_item.cost
                    ? formatMoney(current_item.cost) + ' CR'
                    : 'N/A CR'}
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={6}>
            <Section
              fill
              height="100%"
              scrollable
              title={
                <Box textAlign="center" fontSize={2}>
                  {' '}
                  Past Bidders
                </Box>
              }>
              {bidders.map((item) => (
                <Box key={item.name} className="candystripe" p={1} pb={2}>
                  <Stack align="baseline">
                    <Stack.Item grow bold>
                      {item.name}
                    </Stack.Item>
                    <Stack.Item>{formatMoney(item.amount) + ' cr'}</Stack.Item>
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow={2}>
            <Stack fill>
              <Stack.Item width="70%">
                <Stack vertical fill>
                  <Stack.Item grow fontSize="16px">
                    {time_left
                      ? 'Time Left: ' + formatTime(time_left)
                      : 'Time Left: No Auction'}
                  </Stack.Item>
                  <Stack.Item grow>
                    <Slider
                      name="Bid Amount"
                      position="relative"
                      height="100%"
                      format={(value) => 'Bid Amount: ' + round(value)}
                      step={1}
                      value={
                        current_item.cost
                          ? current_bid
                            ? current_bid
                            : current_item.cost
                          : 1
                      }
                      minValue={current_item.cost ? current_item.cost : 1}
                      maxValue={
                        current_item.cost ? current_item.cost + 1000 : 1
                      }
                      width="100%"
                      color={'invisible'}
                      onDrag={(e, value) =>
                        act('set_bid', {
                          bid: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item width="30%" height="100%">
                <Button
                  width="100%"
                  height="100%"
                  content="Bid"
                  onClick={() =>
                    act('bid', {
                      item: item.id,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item width="50%">
        <Stack vertical fill>
          <Stack.Item grow={8}>
            <Section
              fill
              height="100%"
              scrollable
              title={
                <Box textAlign="center" fontSize={2}>
                  {' '}
                  Upcoming Auctions
                </Box>
              }>
              {queued_items.map((item) => (
                <Box key={item.name} className="candystripe" p={1} pb={2}>
                  <Stack align="baseline">
                    <Stack.Item grow bold>
                      {item.name}
                    </Stack.Item>
                    <Stack.Item color="label">
                      {item.time_until_auction
                        ? formatTime(item.time_until_auction)
                        : ''}
                    </Stack.Item>
                    <Stack.Item>
                      {formatMoney(item.starting_cost) + ' cr'}
                    </Stack.Item>
                  </Stack>
                  {item.desc}
                </Box>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow={2}>
            <Button
              width="100%"
              height="100%"
              content="Reroll the Auction Block"
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

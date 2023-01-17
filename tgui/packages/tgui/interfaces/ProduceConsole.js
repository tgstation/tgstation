import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Icon, NumberInput, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

const buttonWidth = 2;

const TAB2NAME = [
  {
    component: () => ShoppingTab,
  },
  {
    component: () => CheckoutTab,
  },
];

const ShoppingTab = (props, context) => {
  const { data, act } = useBackend(context);
  const { credit_type, order_categories, order_datums } = data;
  const [shopIndex, setShopIndex] = useLocalState(context, 'shop-index', 1);
  const [condensed, setCondensed] = useLocalState(context, 'condensed', false);
  const mapped_food = order_datums.filter(
    (food) => food && food.cat === shopIndex
  );
  return (
    <Stack fill vertical>
      <Section mb={-0.9}>
        <Stack.Item>
          <Tabs>
            {order_categories.map((item, key) => (
              <Tabs.Tab
                key={item.id}
                selected={item === shopIndex}
                onClick={() => setShopIndex(item)}>
                {item}
              </Tabs.Tab>
            ))}
          </Tabs>
          <Button
            ml={65}
            mt={-2}
            color={condensed ? 'green' : 'red'}
            content={condensed ? 'Uncondense' : 'Condense'}
            onClick={() => setCondensed(!condensed)}
          />
        </Stack.Item>
      </Section>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical mt={-2}>
            <Divider />
            {mapped_food.map((item) => (
              <Stack.Item key={item}>
                <Stack>
                  <span
                    style={{
                      'vertical-align': 'middle',
                    }}
                  />{' '}
                  {!condensed && (
                    <Stack.Item>
                      <Box
                        as="img"
                        m={1}
                        src={`data:image/jpeg;base64,${item.product_icon}`}
                        height="36px"
                        width="36px"
                        style={{
                          '-ms-interpolation-mode': 'nearest-neighbor',
                          'vertical-align': 'middle',
                        }}
                      />
                    </Stack.Item>
                  )}
                  <Stack.Item>{capitalize(item.name)}</Stack.Item>
                  <Stack.Item grow mt={-1} color="label" fontSize="10px">
                    <Button
                      color="transparent"
                      icon="info"
                      tooltipPosition="right"
                      tooltip={item.desc}
                    />
                    <br />
                  </Stack.Item>
                  <Stack.Item mt={-0.5}>
                    <Box fontSize="10px" color="label" textAlign="right">
                      {' costs ' + item.cost + item.credit_type + ' per order.'}
                    </Box>
                    <Button
                      icon="minus"
                      onClick={() =>
                        act('remove_one', {
                          target: item.ref,
                        })
                      }
                    />
                    <Button
                      icon="plus"
                      onClick={() =>
                        act('add_one', {
                          target: item.ref,
                        })
                      }
                    />
                    <NumberInput
                      animated
                      value={item.amt || 0}
                      width="41px"
                      minValue={0}
                      maxValue={20}
                      onChange={(e, value) =>
                        act('cart_set', {
                          target: item.ref,
                          amt: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
                <Divider />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const CheckoutTab = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    credit_type,
    purchase_tooltip,
    express_tooltip,
    forced_express,
    order_datums,
    total_cost,
  } = data;
  const checkout_list = order_datums.filter((food) => food && (food.amt || 0));
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical fill>
            <Stack.Item textAlign="center">Checkout list:</Stack.Item>
            <Divider />
            {!checkout_list.length && (
              <>
                <Box align="center" mt="15%" fontSize="40px">
                  Nothing!
                </Box>
                <br />
                <Box align="center" mt={2} fontSize="15px">
                  (Go order something, will ya?)
                </Box>
              </>
            )}
            <Stack.Item grow>
              {checkout_list.map((item) => (
                <Stack.Item key={item}>
                  <Stack>
                    <Stack.Item>{capitalize(item.name)}</Stack.Item>
                    <Stack.Item grow mt={-1} color="label" fontSize="10px">
                      {'"' + item.desc + '"'}
                      <br />
                      <Box textAlign="right">
                        {item.name +
                          ' costs ' +
                          item.cost +
                          item.credit_type +
                          ' per order.'}
                      </Box>
                    </Stack.Item>
                    <Stack.Item mt={-0.5}>
                      <NumberInput
                        value={item.amt || 0}
                        width="41px"
                        minValue={0}
                        maxValue={(item.cost > 10 && 50) || 10}
                        onChange={(e, value) =>
                          act('cart_set', {
                            target: item.ref,
                            amt: value,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                  <Divider />
                </Stack.Item>
              ))}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Stack>
            <Stack.Item grow mt={0.5}>
              Total Cost: {total_cost}
            </Stack.Item>
            {!forced_express && (
              <Stack.Item grow textAlign="center">
                <Button
                  fluid
                  icon="plane-departure"
                  content="Purchase"
                  tooltip={purchase_tooltip}
                  tooltipPosition="top"
                  onClick={() => act('purchase')}
                />
              </Stack.Item>
            )}
            <Stack.Item grow textAlign="center">
              <Button
                fluid
                icon="parachute-box"
                color="yellow"
                content="Express"
                tooltip={express_tooltip}
                tooltipPosition="top-start"
                onClick={() => act('express')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const OrderSent = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon ml="28%" color="green" name="plane-arrival" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="green">
          Order sent! Machine on cooldown...
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const ProduceConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { points, off_cooldown } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, 'tab-index', 1);
  const TabComponent = TAB2NAME[tabIndex - 1].component();
  return (
    <Window width={500} height={400}>
      <Window.Content>
        {!off_cooldown && <OrderSent />}
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <Stack textAlign="center">
                <Stack.Item grow={3}>
                  <Button
                    fluid
                    color="green"
                    lineHeight={buttonWidth}
                    icon="cart-plus"
                    content="Shopping"
                    onClick={() => setTabIndex(1)}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    color="green"
                    lineHeight={buttonWidth}
                    icon="dollar-sign"
                    content="Checkout"
                    onClick={() => setTabIndex(2)}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Section>
            <Stack grow>
              <Stack.Item>
                Currently available balance: {points || 0}
              </Stack.Item>
            </Stack>
          </Section>
          <Stack.Item grow>
            <TabComponent />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

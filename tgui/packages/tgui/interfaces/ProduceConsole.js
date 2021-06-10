import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Icon, NumberInput, Section, Stack } from '../components';
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
  const {
    order_datums,
  } = data;
  const [
    shopIndex,
    setShopIndex,
  ] = useLocalState(context, 'shop-index', 1);
  const mapped_food = order_datums.filter(food => (
    food && food.cat === shopIndex
  ));
  return (
    <Stack fill vertical>
      <Section mb={-0.9}>
        <Stack.Item>
          <Stack textAlign="center">
            <Stack.Item grow>
              <Button
                fluid
                color="green"
                content="Fruits and Veggies"
                onClick={() => setShopIndex(1)} />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                color="white"
                content="Milk and Eggs"
                onClick={() => setShopIndex(2)} />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                color="olive"
                content="Sauces and Reagents"
                onClick={() => setShopIndex(3)} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Section>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical mt={-2}>
            <Divider />
            {mapped_food.map(item => (
              <Stack.Item key={item}>
                <Stack>
                  <Stack.Item grow>
                    {item.name}
                  </Stack.Item>
                  <Stack.Item mt={-1} color="label" fontSize="10px">
                    {"\""+item.desc+"\""}
                    <br />
                    <Box textAlign="right">
                      {item.name+" costs "+item.cost+" per order."}
                    </Box>
                  </Stack.Item>
                  <Stack.Item mt={-0.5}>
                    <NumberInput
                      animated
                      value={item.amt && item.amt || 0}
                      width="41px"
                      minValue={0}
                      maxValue={20}
                      onChange={(e, value) => act('cart_set', {
                        target: item.ref,
                        amt: value,
                      })} />
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
    order_datums,
    total_cost,
  } = data;
  const checkout_list = order_datums.filter(food => (
    food && food.amt
  ));
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical fill>
            <Stack.Item textAlign="center">
              Checkout list:
            </Stack.Item>
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
              {checkout_list.map(item => (
                <Stack.Item key={item}>
                  <Stack>
                    <Stack.Item grow>
                      {item.name}
                    </Stack.Item>
                    <Stack.Item mt={-1} color="label" fontSize="10px">
                      {"\""+item.desc+"\""}
                      <br />
                      <Box textAlign="right">
                        {item.name+" costs "+item.cost+" per order."}
                      </Box>
                    </Stack.Item>
                    <Stack.Item mt={-0.5}>
                      <NumberInput
                        value={item.amt && item.amt || 0}
                        width="41px"
                        minValue={0}
                        maxValue={item.cost > 10 && 50 || 10}
                        onChange={(e, value) => act('cart_set', {
                          target: item.ref,
                          amt: value,
                        })} />
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
            <Stack.Item grow textAlign="center">
              <Button
                fluid
                icon="plane-departure"
                content="Purchase"
                tooltip={multiline`
                Your groceries will arrive at cargo,
                and hopefully get delivered by them.
                `}
                tooltipPosition="top"
                onClick={() => act('purchase')} />
            </Stack.Item>
            <Stack.Item grow textAlign="center">
              <Button
                fluid
                icon="parachute-box"
                color="yellow"
                content="Express"
                tooltip={multiline`
                Sends the ingredients instantly,
                and locks the console longer. Doubles the price!
                `}
                tooltipPosition="top-start"
                onClick={() => act('express')} />
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
          <Icon
            ml="28%"
            color="green"
            name="plane-arrival"
            size={10}
          />
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
  const {
    off_cooldown,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 1);
  const TabComponent = TAB2NAME[tabIndex-1].component();
  return (
    <Window
      title="Produce Orders"
      width={500}
      height={400}>
      <Window.Content>
        {!off_cooldown && (
          <OrderSent />
        )}
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
                    onClick={() => setTabIndex(1)} />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    color="green"
                    lineHeight={buttonWidth}
                    icon="dollar-sign"
                    content="Checkout"
                    onClick={() => setTabIndex(2)} />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <TabComponent />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

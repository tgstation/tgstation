import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Flex, NoticeBox, NumberInput, Section, Stack } from '../components';
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
          <Stack>
            <Stack.Item>
              <Button
                color="green"
                content="Fruits and Veggies"
                onClick={() => setShopIndex(1)} />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="white"
                content="Milk and Eggs"
                onClick={() => setShopIndex(2)} />
            </Stack.Item>
            <Stack.Item>
              <Button
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
                      maxValue={50}
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
            {checkout_list.length && (
              <Divider />
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
                        animated
                        value={item.amt && item.amt || 0}
                        width="41px"
                        minValue={0}
                        maxValue={50}
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
            <Stack.Item mt={0.5}>
              Total Cost: {total_cost}
            </Stack.Item>
            <Stack.Item grow textAlign="center">
              <Button
                fluid
                content="Purchase"
                onClick={() => act('purchase')} />
            </Stack.Item>
            <Stack.Item textAlign="center">
              <Button
                fluid
                color="yellow"
                content="Express"
                onClick={() => act('purchase')} />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const ProduceConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 1);
  const TabComponent = TAB2NAME[tabIndex-1].component();
  return (
    <Window
      title="Produce Orders"
      width={400}
      height={400}>
      <Window.Content>
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

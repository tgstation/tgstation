import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  DmIcon,
  Icon,
  Input,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { capitalize, createSearch } from 'tgui-core/string';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

const buttonWidth = 2;

type OrderDatum = {
  name: string;
  desc: number;
  cat: string;
  ref: string;
  cost: number;
  icon: string;
  icon_state: string;
};

type Item = {
  name: string;
  amt: number;
};

type Data = {
  credit_type: string;
  off_cooldown: BooleanLike;
  points: number;
  express_tooltip: string;
  purchase_tooltip: string;
  forced_express: string;
  cargo_value: number;
  cargo_cost_multiplier: number;
  express_cost_multiplier: number;
  order_categories: string[];
  order_datums: OrderDatum[];
  item_amts: Item[];
  total_cost: number;
};

const TAB2NAME = [
  {
    component: () => ShoppingTab,
  },
  {
    component: () => CheckoutTab,
  },
];

const findAmount = (item_amts, name) => {
  const amount = item_amts.find((item) => item.name === name);
  return amount.amt;
};

const ShoppingTab = (props) => {
  const { data, act } = useBackend<Data>();
  const { credit_type, order_categories, order_datums, item_amts } = data;
  const [shopCategory, setShopCategory] = useState(order_categories[0]);
  const [condensed] = useLocalState('condensed', false);
  const [searchItem, setSearchItem] = useState('');
  const search = createSearch<OrderDatum>(
    searchItem,
    (order_datums) => order_datums.name,
  );
  let goods =
    searchItem.length > 0
      ? order_datums.filter((item) => search(item))
      : order_datums.filter((item) => item && item.cat === shopCategory);

  return (
    <Stack fill vertical>
      <Section mb={-1}>
        <Stack.Item>
          <Tabs fluid textAlign="center">
            {order_categories.map((category) => (
              <Tabs.Tab
                key={category}
                selected={category === shopCategory}
                onClick={() => {
                  setShopCategory(category);
                  if (searchItem.length > 0) {
                    setSearchItem('');
                  }
                }}
              >
                {category}
              </Tabs.Tab>
            ))}
            <Stack.Item>
              <Input
                autoFocus
                mt={0.5}
                width="150px"
                placeholder="Search item..."
                value={searchItem}
                onInput={(e, value) => {
                  setSearchItem(value);
                }}
              />
            </Stack.Item>
          </Tabs>
        </Stack.Item>
      </Section>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical mt={-2}>
            <Divider />
            {goods.map((item) => (
              <Stack.Item key={item.ref}>
                <Stack>
                  <span
                    style={{
                      verticalAlign: 'middle',
                    }}
                  />{' '}
                  {!condensed && (
                    <Stack.Item>
                      <DmIcon
                        icon={item.icon}
                        icon_state={item.icon_state}
                        verticalAlign="middle"
                        height={'36px'}
                        width={'36px'}
                        fallback={<Icon name="spinner" size={2} spin />}
                      />
                    </Stack.Item>
                  )}
                  <Stack.Item grow>{capitalize(item.name)}</Stack.Item>
                  <Stack.Item color="label" fontSize="10px">
                    <Button
                      mt={-1}
                      color="transparent"
                      icon="info"
                      tooltipPosition="right"
                      tooltip={item.desc}
                    />
                    <br />
                  </Stack.Item>
                  <Stack.Item mt={-1.5} align="right">
                    <Box fontSize="10px" color="label">
                      {item.cost + credit_type + ' per order.'}
                    </Box>
                    <Button
                      icon="minus"
                      ml={2}
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
                      value={findAmount(item_amts, item.name) || 0}
                      width="41px"
                      minValue={0}
                      maxValue={20}
                      step={1}
                      onChange={(value) =>
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

const CheckoutTab = (props) => {
  const { data, act } = useBackend<Data>();
  const {
    credit_type,
    purchase_tooltip,
    express_tooltip,
    forced_express,
    cargo_value,
    order_datums,
    total_cost,
    cargo_cost_multiplier,
    express_cost_multiplier,
    item_amts,
  } = data;
  const total_cargo_cost = Math.floor(total_cost * cargo_cost_multiplier);
  const checkout_list = order_datums.filter(
    (food) => food && (findAmount(item_amts, food.name) || 0),
  );
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
              {checkout_list.map((item, key) => (
                <Stack.Item key={key}>
                  <Stack>
                    <Stack.Item>{capitalize(item.name)}</Stack.Item>
                    <Stack.Item grow color="label" fontSize="10px">
                      {'"' + item.desc + '"'}
                      <br />
                      <Box textAlign="right">
                        {item.name +
                          ' costs ' +
                          item.cost +
                          credit_type +
                          ' per order.'}
                      </Box>
                    </Stack.Item>
                    <Stack.Item mt={-0.5}>
                      <NumberInput
                        value={findAmount(item_amts, item.name) || 0}
                        width="41px"
                        minValue={0}
                        maxValue={(item.cost > 10 && 50) || 10}
                        step={1}
                        onChange={(value) =>
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
              Total:{total_cargo_cost}&#40;Express:
              {total_cost * express_cost_multiplier}&#41;
            </Stack.Item>
            {!forced_express && (
              <Stack.Item grow textAlign="center">
                <Button
                  fluid
                  icon="plane-departure"
                  content="Purchase"
                  disabled={total_cargo_cost < cargo_value}
                  tooltip={
                    total_cargo_cost < cargo_value
                      ? `Total must be above or equal to ${cargo_value}`
                      : purchase_tooltip
                  }
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
                disabled={total_cost <= 0}
                tooltip={
                  total_cost <= 0 ? 'Order atleast 1 item' : express_tooltip
                }
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

const OrderSent = (props) => {
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

export const ProduceConsole = (props) => {
  const { data } = useBackend<Data>();
  const { credit_type, points, off_cooldown, order_categories } = data;
  const [tabIndex, setTabIndex] = useState(1);
  const [condensed, setCondensed] = useLocalState('condensed', false);
  const TabComponent = TAB2NAME[tabIndex - 1].component();

  return (
    <Window width={Math.max(order_categories.length * 125, 500)} height={400}>
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
            <Stack direction="column">
              <Stack.Item grow>
                Currently available balance: {points || 0} {credit_type}
              </Stack.Item>
              <Stack.Item textAlign="right">
                <Button
                  color={condensed ? 'green' : 'red'}
                  content={condensed ? 'Uncondense' : 'Condense'}
                  onClick={() => setCondensed(!condensed)}
                />
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

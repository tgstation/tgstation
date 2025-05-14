import { atom, useAtom } from 'jotai';
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

import { useBackend } from '../backend';
import { Window } from '../layouts';

type OrderDatum = {
  cat: string;
  cost: number;
  desc: number;
  icon_state: string;
  icon: string;
  name: string;
  ref: string;
};

type Item = {
  name: string;
  amt: number;
};

type Data = {
  cargo_cost_multiplier: number;
  cargo_value: number;
  credit_type: string;
  express_cost_multiplier: number;
  express_tooltip: string;
  forced_express: string;
  item_amts: Item[];
  off_cooldown: BooleanLike;
  order_categories: string[];
  order_datums: OrderDatum[];
  points: number;
  purchase_tooltip: string;
  total_cost: number;
};

const buttonWidth = 2;

const condensedAtom = atom(false);

function findAmount(item_amts: Item[], name: string): number {
  const amount = item_amts.find((item) => item.name === name);
  return amount?.amt || 0;
}

function ShoppingTab(props) {
  const { data, act } = useBackend<Data>();
  const { credit_type, order_categories, order_datums, item_amts } = data;

  const [shopCategory, setShopCategory] = useState(order_categories[0]);
  const [condensed] = useAtom(condensedAtom);
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
                onChange={setSearchItem}
                expensive
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
                      value={findAmount(item_amts, item.name)}
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
}

function CheckoutTab(props) {
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
    (food) => food && findAmount(item_amts, food.name),
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
              {checkout_list.map((item, index) => (
                <Stack.Item key={index}>
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
                        value={findAmount(item_amts, item.name)}
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
                  disabled={total_cargo_cost < cargo_value}
                  tooltip={
                    total_cargo_cost < cargo_value
                      ? `Total must be above or equal to ${cargo_value}`
                      : purchase_tooltip
                  }
                  tooltipPosition="top"
                  onClick={() => act('purchase')}
                >
                  Purchase
                </Button>
              </Stack.Item>
            )}
            <Stack.Item grow textAlign="center">
              <Button
                fluid
                icon="parachute-box"
                color="yellow"
                disabled={total_cost <= 0}
                tooltip={
                  total_cost <= 0 ? 'Order atleast 1 item' : express_tooltip
                }
                tooltipPosition="top-start"
                onClick={() => act('express')}
              >
                Express
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function OrderSent(props) {
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
}

enum Tab {
  Shopping,
  Checkout,
}

export function ProduceConsole(props) {
  const { data } = useBackend<Data>();
  const { credit_type, points, off_cooldown, order_categories } = data;

  const [tabIndex, setTabIndex] = useState(Tab.Shopping);
  const [condensed, setCondensed] = useAtom(condensedAtom);

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
                    onClick={() => setTabIndex(Tab.Shopping)}
                  >
                    Shopping
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    color="green"
                    lineHeight={buttonWidth}
                    icon="dollar-sign"
                    onClick={() => setTabIndex(Tab.Checkout)}
                  >
                    Checkout
                  </Button>
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
                  onClick={() => setCondensed(!condensed)}
                >
                  {condensed ? 'Uncondense' : 'Condense'}
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
          <Stack.Item grow>
            {tabIndex === Tab.Shopping && <ShoppingTab />}
            {tabIndex === Tab.Checkout && <CheckoutTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

import { atom, useAtom } from 'jotai';
import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  DmIcon,
  Icon,
  Input,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
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

const creditIcons = {
  credit: 'coins',
} as const;

type CreditIconProps = {
  credit_type: string;
  color?: string;
};

function CreditIcon(props: CreditIconProps) {
  const { credit_type, color = 'gold' } = props;

  const foundIcon = creditIcons[credit_type];
  if (!foundIcon) return credit_type;

  return <Icon name={foundIcon} color={color} />;
}

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

  const goods =
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
              />
            </Stack.Item>
          </Tabs>
        </Stack.Item>
      </Section>
      <Stack.Item grow>
        <Section fill scrollable>
          <Table>
            {goods.map((item) => (
              <Table.Row
                key={item.ref}
                style={{ borderBottom: 'thin solid #333' }}
              >
                {!condensed && (
                  <Table.Cell collapsing>
                    <DmIcon
                      icon={item.icon}
                      icon_state={item.icon_state}
                      verticalAlign="middle"
                      height="36px"
                      width="36px"
                      fallback={<Icon name="spinner" size={2} spin />}
                    />
                  </Table.Cell>
                )}
                <Table.Cell color="label">{capitalize(item.name)}</Table.Cell>
                <Table.Cell color="label" fontSize="10px" collapsing>
                  <Button
                    color="transparent"
                    icon="info"
                    tooltipPosition="top"
                    tooltip={item.desc}
                  />
                </Table.Cell>
                <Table.Cell fontSize="10px" collapsing textAlign="right">
                  <Tooltip
                    content={`Costs ${item.cost} ${credit_type} per order`}
                    position="top"
                  >
                    {item.cost} <CreditIcon credit_type={credit_type} />
                  </Tooltip>
                </Table.Cell>
                <Table.Cell collapsing>
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
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
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
          <Table>
            <Table.Row>
              <Table.Cell header colSpan={3} textAlign="center" color="label">
                Checkout list:
              </Table.Cell>
            </Table.Row>
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
            {checkout_list.map((item, index) => (
              <Table.Row
                key={item.ref}
                style={{ borderBottom: 'thin solid #333' }}
              >
                <Table.Cell collapsing>{capitalize(item.name)}</Table.Cell>
                <Table.Cell color="label" fontSize="10px">
                  {`"${item.desc}"`}
                </Table.Cell>
                <Table.Cell fontSize="10px" collapsing textAlign="right">
                  <Tooltip
                    content={`Costs ${item.cost} ${credit_type} per order`}
                    position="top"
                  >
                    {item.cost} <CreditIcon credit_type={credit_type} />
                  </Tooltip>
                </Table.Cell>
                <Table.Cell collapsing>
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
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill>
          <Stack fill>
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
                  Purchase: {total_cargo_cost}{' '}
                  <CreditIcon credit_type={credit_type} color="white" />
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
                Express: {total_cost * express_cost_multiplier}{' '}
                <CreditIcon credit_type={credit_type} color="black" />
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
  const { credit_type, points = 0, off_cooldown, order_categories } = data;

  const [tabIndex, setTabIndex] = useState(Tab.Shopping);
  const [condensed, setCondensed] = useAtom(condensedAtom);

  return (
    <Window width={Math.max(order_categories.length * 125, 500)} height={400}>
      <Window.Content>
        {!off_cooldown && <OrderSent />}
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <Stack fill vertical>
                <Stack.Item>
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
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        color={condensed ? 'green' : 'red'}
                        onClick={() => setCondensed(!condensed)}
                      >
                        {condensed ? 'Expand' : 'Condense'}
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      {points} <CreditIcon credit_type={credit_type} />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {tabIndex === Tab.Shopping && <ShoppingTab />}
            {tabIndex === Tab.Checkout && <CheckoutTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

import { BooleanLike } from 'common/react';
import { toTitleCase } from 'common/string';

import { useBackend } from '../backend';
import { Button, Modal, Section, Stack } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

type Material = {
  name: string;
  quantity: number;
  trend: string;
  price: number;
  threshold: number;
  color: string;
  requested: number;
};

type Data = {
  orderingPrive: BooleanLike;
  canOrderCargo: BooleanLike;
  creditBalance: number;
  orderBalance: number;
  materials: Material[];
  catastrophe: BooleanLike;
  CARGO_CRATE_VALUE: number;
};

export const MatMarket = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    orderingPrive,
    canOrderCargo,
    creditBalance,
    orderBalance,
    materials = [],
    catastrophe,
    CARGO_CRATE_VALUE,
  } = data;

  // offset cost with crate value if there is currently nothing in the order
  const total_order_cost = orderBalance || CARGO_CRATE_VALUE;
  // multiplier of 1.1 for private orders
  const multiplier = orderingPrive ? 1.1 : 1;

  return (
    <Window width={880} height={690}>
      <Window.Content scrollable>
        {!!catastrophe && <MarketCrashModal />}
        <Section
          title="Materials for sale"
          buttons={
            !!canOrderCargo && (
              <Button
                icon="dollar"
                tooltip="Place order from cargo budget."
                color={orderingPrive ? '' : 'green'}
                content={
                  orderingPrive
                    ? 'Order via Cargo Budget?'
                    : 'Ordering via Cargo Budget'
                }
                onClick={() => act('toggle_budget')}
              />
            )
          }
        >
          Buy orders for material sheets placed here will be ordered on the next
          cargo shipment.
          <br /> <br />
          To <b>sell materials</b>, please insert sheets or similar stacks of
          materials. All minerals sold on the market directly are subject to an
          20% market fee. To prevent market manipulation, all registered traders
          can buy a total of <b>10 full stacks of materials at a time</b>.
          <br /> <br />
          All new purchases will <b>include the cost of the shipped crate</b>,
          which may be recycled afterwards.
          <Section>
            <Stack>
              <Stack.Item width="232px">
                Current Credit Balance: <b>{formatMoney(creditBalance)}</b> cr.
              </Stack.Item>
              <Stack.Item width="232px">
                Current Order Cost: <b>{formatMoney(orderBalance)}</b> cr.
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="times"
                  color="transparent"
                  ml={66}
                  onClick={() => act('clear')}
                >
                  Clear
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Section>
        {materials.map((material, i) => (
          <Section key={i}>
            <Stack fill>
              <Stack.Item width="75%">
                <Stack>
                  <Stack.Item
                    textColor={material.color ? material.color : 'white'}
                    fontSize="125%"
                    width="15%"
                    pr="3%"
                  >
                    {toTitleCase(material.name)}
                  </Stack.Item>

                  <Stack.Item width="15%" pr="2%">
                    Trading at <b>{formatMoney(material.price)}</b> cr.
                  </Stack.Item>
                  {material.price < material.threshold ? (
                    <Stack.Item width="33%" ml={2} textColor="grey">
                      Material price critical!
                      <br /> <b>Trading temporarily suspended.</b>
                    </Stack.Item>
                  ) : (
                    <Stack.Item width="33%" ml={2}>
                      <b>{material.quantity || 'Zero'}</b> sheets of{' '}
                      <b>{material.name}</b> trading.{' '}
                      {material.requested || 'Zero'} sheets ordered.
                    </Stack.Item>
                  )}

                  <Stack.Item
                    width="40%"
                    color={
                      material.trend === 'up'
                        ? 'green'
                        : material.trend === 'down'
                          ? 'red'
                          : 'white'
                    }
                  >
                    <b>{toTitleCase(material.name)}</b> is trending{' '}
                    <b>{material.trend}</b>.
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={
                    catastrophe === 1 ||
                    material.price <= material.threshold ||
                    creditBalance - total_order_cost <
                      material.price * multiplier ||
                    material.requested + 1 > material.quantity
                  }
                  tooltip={material.price * 1}
                  onClick={() =>
                    act('buy', {
                      quantity: 1,
                      material: material.name,
                    })
                  }
                >
                  Buy 1
                </Button>
                <Button
                  disabled={
                    catastrophe === 1 ||
                    material.price <= material.threshold ||
                    creditBalance - total_order_cost <
                      material.price * 5 * multiplier ||
                    material.requested + 5 > material.quantity
                  }
                  tooltip={material.price * 5}
                  onClick={() =>
                    act('buy', {
                      quantity: 5,
                      material: material.name,
                    })
                  }
                >
                  5
                </Button>
                <Button
                  disabled={
                    catastrophe === 1 ||
                    material.price <= material.threshold ||
                    creditBalance - total_order_cost <
                      material.price * 10 * multiplier ||
                    material.requested + 10 > material.quantity
                  }
                  tooltip={material.price * 10}
                  onClick={() =>
                    act('buy', {
                      quantity: 10,
                      material: material.name,
                    })
                  }
                >
                  10
                </Button>
                <Button
                  disabled={
                    catastrophe === 1 ||
                    material.price <= material.threshold ||
                    creditBalance - total_order_cost <
                      material.price * 25 * multiplier ||
                    material.requested + 25 > material.quantity
                  }
                  tooltip={material.price * 25}
                  onClick={() =>
                    act('buy', {
                      quantity: 25,
                      material: material.name,
                    })
                  }
                >
                  25
                </Button>
                <Button
                  disabled={
                    catastrophe === 1 ||
                    material.price <= material.threshold ||
                    creditBalance - total_order_cost <
                      material.price * 50 * multiplier ||
                    material.requested + 50 > material.quantity
                  }
                  tooltip={material.price * 50}
                  onClick={() =>
                    act('buy', {
                      quantity: 50,
                      material: material.name,
                    })
                  }
                >
                  50
                </Button>
              </Stack.Item>
              {material.requested > 0 && (
                <Stack.Item ml={2}>x {material.requested}</Stack.Item>
              )}
            </Stack>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};

const MarketCrashModal = (props) => {
  return (
    <Modal textAlign="center" mr={1.5}>
      ATTENTION! THE MARKET HAS CRASHED
      <br /> <br />
      ALL MATERIALS ARE NOW WORTHLESS
      <br /> <br />
      TRADING CIRCUIT BREAKER HAS BEEN ENGAGED FOR ALL TRADERS
      <br /> <br />
      <b>DO NOT PANIC, WE ARE FIXING THIS</b>
    </Modal>
  );
};

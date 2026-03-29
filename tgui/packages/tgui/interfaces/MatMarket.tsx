import { sortBy } from 'es-toolkit';
import {
  Box,
  Button,
  Collapsible,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Material = {
  name: string;
  quantity: number;
  rarity: number;
  trend: string;
  price: number;
  min_threshold: number;
  max_threshold: number;
  color: string;
  requested: number;
  elastic: number;
};

type Data = {
  orderingPrive: BooleanLike;
  canOrderCargo: BooleanLike;
  creditBalance: number;
  orderBalance: number;
  materials: Material[];
  catastrophe: BooleanLike;
  CARGO_CRATE_VALUE: number;
  updateTime: number;
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
    <Window width={990} height={615}>
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
          <NoticeBox info>
            <Collapsible title="Instructions" color="blue">
              Buy orders for material sheets placed here will be ordered on the
              next cargo shipment.
              <br /> <br />
              To sell materials, please insert sheets or similar stacks of
              materials. All minerals sold on the market directly are subject to
              a scaling value decrease per material, but this will recover over
              time. To prevent market manipulation, all registered traders can
              buy a total of 10 full stacks of materials at a time.
              <br /> <br />
              When selling materials, prices will be decreased based on the
              elastic modifier of the material, which will recover over time.
              <br /> <br />
              All new purchases will include the cost of the shipped crate,
              which may be recycled afterwards.
            </Collapsible>
          </NoticeBox>
          <Section>
            <Stack>
              <Stack.Item width="15%">
                Balance: <b>{formatMoney(creditBalance)}</b> cr.
              </Stack.Item>
              <Stack.Item width="15%">
                Order: <b>{formatMoney(orderBalance)}</b> cr.
              </Stack.Item>
              <Stack.Item
                width="20%"
                color={data.updateTime > 150 ? 'green' : '#ad7526'}
              >
                <b>{Math.round(data.updateTime / 10)} seconds</b> until next
                update
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
        {sortBy(materials, [(tempmat: Material) => tempmat.rarity]).map(
          (material, i) => (
            <Section key={i}>
              <Stack fill>
                <Stack.Item width="82%">
                  <Stack>
                    <Stack.Item
                      textColor={material.color ? material.color : 'white'}
                      fontSize="125%"
                      width="15%"
                      pr="3%"
                    >
                      {toTitleCase(material.name)}
                    </Stack.Item>
                    <Stack.Item
                      width="10%"
                      pr="2%"
                      textColor={
                        material.elastic < 33
                          ? 'red'
                          : material.elastic < 66
                            ? 'orange'
                            : 'green'
                      }
                    >
                      Elasticity: <b>{Math.round(material.elastic)}</b>%
                    </Stack.Item>

                    <Stack.Item
                      width="15%"
                      pr="2%"
                      >
                      <Tooltip
                        content={rangeText({ minPrice: material.min_threshold, maxPrice: material.max_threshold })}
                      >
                        <u>Trading at <br /><b>{formatMoney(material.price)}</b> cr.</u>
                      </Tooltip>

                    </Stack.Item>
                    {material.price < material.min_threshold ? (
                      <Stack.Item width="33%" ml={2} textColor="grey">
                        Material price critical!
                        <br /> <b>Trading temporarily suspended.</b>
                      </Stack.Item>
                    ) : (
                      <Stack.Item width="33%" ml={2}>
                        <Box textColor={material.quantity === 0 ? 'grey' : 'white'}>
                          <b>{material.quantity || 'Zero'}</b> sheets of{' '}
                          <b>{material.name}</b> trading.{' '}
                        </Box>
                        <Box
                          bold={!!material.requested}
                          textColor={material.requested > 0 ? 'lightblue' : 'white'}
                        >
                          {material.requested || 'Zero'} sheets ordered.
                        </Box>
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
                    height="100%"
                    verticalAlignContent="middle"
                    disabled={
                      catastrophe === 1 ||
                      material.price < material.min_threshold ||
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
                    height="100%"
                    verticalAlignContent="middle"
                    disabled={
                      catastrophe === 1 ||
                      material.price < material.min_threshold ||
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
                    height="100%"
                    verticalAlignContent="middle"
                    disabled={
                      catastrophe === 1 ||
                      material.price < material.min_threshold ||
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
                    height="100%"
                    verticalAlignContent="middle"
                    disabled={
                      catastrophe === 1 ||
                      material.price < material.min_threshold ||
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
                    height="100%"
                    verticalAlignContent="middle"
                    disabled={
                      catastrophe === 1 ||
                      material.price < material.min_threshold ||
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
              </Stack>
            </Section>
          ),
        )}
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

type rangeTextProps = {
  minPrice: number;
  maxPrice: number;
}

function rangeText(props: rangeTextProps) {
  const {minPrice, maxPrice} = props;
  return (
    "This material can be bought and sold between " + formatMoney(minPrice) +
    " - " + formatMoney(maxPrice) + " cr."
  )
}

import { useBackend } from '../backend';
import { Section, Stack, Button, Modal } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { toTitleCase } from 'common/string';

type Data = {
  orderingPrive: BooleanLike; // you will need to import this
  canOrderCargo: BooleanLike;
  creditBalance: number;
  materials: Material[];
  catastrophe: BooleanLike;
};

type Material = {
  name: string;
  quantity: number;
  id: string; // correct this if its a number
  trend: string;
  price: number;
  color: string;
};

export const MatMarket = (props, context) => {
  const { act, data } = useBackend<Data>(context); // this will tell your editor that data is the type listed above

  const {
    orderingPrive,
    canOrderCargo,
    creditBalance,
    materials = [],
    catastrophe,
  } = data; // better to destructure here (style nit)
  return (
    <Window width={700} height={400}>
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
          }>
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
            Current credit balance: <b>{creditBalance || 'zero'}</b> cr.
          </Section>
        </Section>
        {materials.map((material) => (
          <Section key={material.id}>
            <Stack fill>
              <Stack.Item width="75%">
                <Stack>
                  <Stack.Item
                    textColor={material.color ? material.color : 'white'}
                    fontSize="125%"
                    width="15%"
                    pr="3%">
                    {toTitleCase(material.name)}
                  </Stack.Item>

                  <Stack.Item width="15%" pr="2%">
                    Trading at <b>{material.price}</b> cr.
                  </Stack.Item>

                  <Stack.Item width="33%">
                    <b>{material.quantity}</b> sheets of <b>{material.name}</b>{' '}
                    trading.
                  </Stack.Item>
                  <Stack.Item
                    width="40%"
                    color={
                      material.trend === 'up'
                        ? 'green'
                        : material.trend === 'down'
                          ? 'red'
                          : 'white'
                    }>
                    <b>{toTitleCase(material.name)}</b> is trending{' '}
                    <b>{material.trend}</b>.
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={catastrophe === 1 || material.price <= 0}
                  tooltip={material.price * 1}
                  onClick={() =>
                    act('buy', {
                      quantity: 1,
                      material: material.name,
                    })
                  }>
                  Buy 1
                </Button>
                <Button
                  disabled={catastrophe === 1 || material.price <= 0}
                  tooltip={material.price * 5}
                  onClick={() =>
                    act('buy', {
                      quantity: 5,
                      material: material.name,
                    })
                  }>
                  5
                </Button>
                <Button
                  disabled={catastrophe === 1 || material.price <= 0}
                  tooltip={material.price * 10}
                  onClick={() =>
                    act('buy', {
                      quantity: 10,
                      material: material.name,
                    })
                  }>
                  10
                </Button>
                <Button
                  disabled={catastrophe === 1 || material.price <= 0}
                  tooltip={material.price * 25}
                  onClick={() =>
                    act('buy', {
                      quantity: 25,
                      material: material.name,
                    })
                  }>
                  25
                </Button>
                <Button
                  disabled={catastrophe === 1 || material.price <= 0}
                  tooltip={material.price * 50}
                  onClick={() =>
                    act('buy', {
                      quantity: 50,
                      material: material.name,
                    })
                  }>
                  50
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};

const MarketCrashModal = (props, context) => {
  const { act, data } = useBackend(context);
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

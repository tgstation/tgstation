import { useBackend } from '../backend';
import { Section, Stack, Button } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { toTitleCase } from 'common/string';

type Data = {
  orderingPrive: BooleanLike; // you will need to import this
  canOrderCargo: BooleanLike;
  creditBalance: number;
  materials: Material[];
};

type Material = {
  name: string;
  quantity: number;
  id: string; // correct this if its a number
  trend: string;
};

export const MatMarket = (props, context) => {
  const { act, data } = useBackend<Data>(context); // this will tell your editor that data is the type listed above

  const { orderingPrive, canOrderCargo, creditBalance, materials = [] } = data; // better to destructure here (style nit)
  return (
    <Window width={700} height={400}>
      <Window.Content scrollable>
        <Section
          title="Materials for sale"
          buttons={
            <Button
              icon="dollar"
              tooltip="Place order from cargo budget."
              color={!!orderingPrive && !!canOrderCargo ? '' : 'green'}
              content={
                !!orderingPrive && !!canOrderCargo
                  ? 'Order via Cargo Budget?'
                  : 'Ordering via Cargo Budget'
              }
              onClick={() => act('toggle_budget')}
            />
          }>
          Buy orders for material sheets placed here will be ordered on the next
          cargo shipment.
          <br />
          To sell materials, please insert sheets or similar stacks of
          materials. All minerals sold on the market directly are subject to an
          20% market fee.
          <Section>
            Current credit balance: <b>{creditBalance || 'zero'}</b> cr.
          </Section>
        </Section>
        {materials.map((material) => (
          <Section key={material.id}>
            <Stack fill>
              <Stack.Item width="75%">
                <Stack>
                  <Stack.Item fontSize="125%" width="15%" pr="3%">
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
                  onClick={() =>
                    act('buy', {
                      quantity: 1,
                      material: material.name,
                    })
                  }>
                  Buy 1
                </Button>
                <Button
                  onClick={() =>
                    act('buy', {
                      quantity: 5,
                      material: material.name,
                    })
                  }>
                  5
                </Button>
                <Button
                  onClick={() =>
                    act('buy', {
                      quantity: 10,
                      material: material.name,
                    })
                  }>
                  10
                </Button>
                <Button
                  onClick={() =>
                    act('buy', {
                      quantity: 25,
                      material: material.name,
                    })
                  }>
                  25
                </Button>
                <Button
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

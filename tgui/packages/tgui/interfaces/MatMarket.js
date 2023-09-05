import { useBackend } from '../backend';
import { Section, Stack, Flex, Button } from '../components';
import { Window } from '../layouts';

export const MatMarket = (props, context) => {
  const { act, data } = useBackend(context);

  const { materials = [] } = data;
  return (
    <Window width={700} height={400}>
      <Window.Content scrollable>
        <Section title="Materials for sale">
          Buy orders for material sheets placed here will be ordered on the next
          cargo shipment.
        </Section>
        {materials.map((material) => (
          <Section title={material.name} key={material.id}>
            <Flex grow={1} basis={0}>
              <Flex.Item width="75%">
                <Stack>
                  <Stack.Item width="15%" pr="2%">
                    Trading at <b>{material.price}</b> cr.
                  </Stack.Item>

                  <Stack.Item width="33%">
                    <b>{material.quantity}</b> sheets of <b>{material.name}</b>{' '}
                    trading.
                  </Stack.Item>
                  <Stack.Item
                    width="33%"
                    color={
                      material.trend === 'up'
                        ? 'green'
                        : material.trend === 'down'
                          ? 'red'
                          : 'white'
                    }>
                    <b>{material.name}</b> is trending <b>{material.trend}</b>.
                  </Stack.Item>
                </Stack>
              </Flex.Item>
              <Flex.Item>
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
              </Flex.Item>
            </Flex>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};

import { useBackend } from '../backend';
import { BlockQuote, Box, Button, Divider, Flex, Stack, Section } from '../components';
import { Window } from '../layouts';

const ItemListEntry = (props) => {
  const {
    product: { name, cost, image },
    disabled,
    onClick,
  } = props;

  return (
    <>
      <Flex direction="row" align="center">
        <Flex.Item>
          <img
            src={`data:image/png;base64,${image}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box bold>{name}</Box>
        </Flex.Item>
        <Flex.Item>
          {`Cost: ${cost}`} <i class="fa-solid fa-coins" />
        </Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            Buy
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </>
  );
};

export const PreRoundStore = (_props) => {
  const { act, data } = useBackend();
  const { balance, items, currently_owned } = data;

  return (
    <Window resizable title="Pre Round Shop" width={450} height={700}>
      <Window.Content scrollable>
        <Section>
          <BlockQuote>
            Purchase an item that will spawn with you round start!
          </BlockQuote>
          <Stack vertical fill>
            {currently_owned ? (
              <Stack.Item>
                <Box>Held Item: {currently_owned}</Box>
              </Stack.Item>
            ) : (
              ''
            )}
            <Stack.Item>
              <Section>
                <Flex direction="row" align="center">
                  <Box>
                    Balance: {balance} <i class="fa-solid fa-coins" />
                  </Box>
                </Flex>
              </Section>
            </Stack.Item>
            <Stack.Item>
              {items.map((purchase) => {
                const { name, cost, path } = purchase;
                return (
                  <ItemListEntry
                    key={name}
                    product={purchase}
                    disabled={balance < cost}
                    onClick={() => act('attempt_buy', { path })}
                  />
                );
              })}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

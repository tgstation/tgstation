import { map } from 'common/collections';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Modal, Section, Table, Tabs } from '../components';
import { Window } from '../layouts';

export const BlackmarketUplink = (props, context) => {
  const { act, data } = useBackend(context);
  const categories = data.categories || [];
  const deliveryMethods = data.delivery_methods || [];
  const deliveryMethodDesc = data.delivery_method_description || [];
  const markets = data.markets || {};
  const items = data.items || {};

  const shipmentSelector = !!data.buying && (
    <Modal textAlign="center">
      <Flex mb={1}>
        {map(deliveryMethod => {
          const name = deliveryMethod.name;
          if (name === "LTSRBT" && !data.ltsrbt_built) {
            return null;
          }
          return (
            <Flex.Item
              key={name}
              mx={1}
              width="250px">
              <Box fontSize="30px">
                {name}
              </Box>
              <Box mt={1}>
                {deliveryMethodDesc[name]}
              </Box>
              <Button
                mt={2}
                content={deliveryMethod.price+' cr'}
                disabled={data.money < deliveryMethod.price}
                onClick={() => act('buy', {
                  method: name,
                })} />
            </Flex.Item>
          );
        })(deliveryMethods)}
      </Flex>
      <Button
        content="Cancel"
        color="bad"
        onClick={() => act('cancel')} />
    </Modal>
  );

  return (
    <Window
      theme="hackerman"
      resizable>
      {shipmentSelector}
      <Window.Content scrollable>
        <Section
          title="Black Market Uplink"
          buttons={(
            <Box inline bold>
              <AnimatedNumber value={Math.round(data.money)} /> cr
            </Box>
          )} />
        <Tabs
          activeTab={data.viewing_market}>
          {map(market => {
            const id = market.id;
            const name = market.name;
            return (
              <Tabs.Tab
                key={id}
                label={name}
                onClick={() => act('set_market', {
                  market: id,
                })} />
            );
          })(markets)}
        </Tabs>
        <Box>
          <Tabs vertical
            activeTab={data.viewing_category}>
            {categories.map(category => (
              <Tabs.Tab
                key={category}
                label={category}
                height={4}
                mt={0.5}
                onClick={() => act('set_category', {
                  category: category,
                })}>
                {items.map(item => (
                  <Table
                    key={item.name}
                    mt={1}
                    className="candystripe">
                    <Table.Row>
                      <Table.Cell bold>
                        {item.name}
                      </Table.Cell>
                      <Table.Cell collapsing textAlign="right">
                        {item.amount ? item.amount+" in stock" : "Out of stock"}
                      </Table.Cell>
                      <Table.Cell collapsing textAlign="right">
                        {item.cost+'cr'}
                      </Table.Cell>
                      <Table.Cell collapsing textAlign="right">
                        <Button
                          content="Buy"
                          disabled={!item.amount || item.cost > data.money}
                          onClick={() => act('select', {
                            item: item.id,
                          })} />
                      </Table.Cell>
                    </Table.Row>
                    <Table.Row>
                      <Table.Cell>
                        {item.desc}
                      </Table.Cell>
                    </Table.Row>
                  </Table>
                ))}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Box>
      </Window.Content>
    </Window>
  );
};

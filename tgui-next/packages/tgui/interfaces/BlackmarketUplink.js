import { map } from 'common/collections';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Dimmer, Box, Button, Section, Tabs, AnimatedNumber, Table, Grid } from '../components';

export const BlackmarketUplink = props => {
  const { act, data } = useBackend(props);
  const categories = data.categories || [];
  const deliveryMethods = data.delivery_methods || [];
  const deliveryMethodDesc = data.delivery_method_description || [];
  const markets = data.markets || {};
  const items = data.items || {};

  const shipmentSelector = !!data.buying && (
    <Dimmer
      textAlign="center">
      <Grid mt={20}>
        {map(deliveryMethod => {
          const name = deliveryMethod.name;
          if (name === "LTSRBT" && !data.ltsrbt_built) {
            return null;
          }

          return (
            <Grid.Column
              textAlign="center"
              position="relative">
              <Box>
                <Box
                  fontSize="30px">
                  {name}
                </Box>
                <Box mt={1}>
                  {deliveryMethodDesc[name]}
                </Box>
              </Box>
              <Button
                key={name}
                content={deliveryMethod.price+' cr'}
                mt={1}
                disabled={data.money < deliveryMethod.price}
                onClick={() => act('buy', {
                  method: name,
                })} />
            </Grid.Column>
          );
        })(deliveryMethods)}
      </Grid>
      <Button
        content="Cancel"
        color="bad"
        onClick={() => act('cancel')} />
    </Dimmer>
  );

  return (
    <Fragment>
      {shipmentSelector}
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
              })}>
            </Tabs.Tab>
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
                        content={'Buy'}
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
    </Fragment>
  );
};

import { Fragment } from 'inferno';
import { act } from '../byond';
import { Section, Box, Button, Table } from '../components';
import { classes } from 'common/react';

export const Vending = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  let inventory;
  let custom = false;
  if (data.vending_machine_input) {
    inventory = data.vending_machine_input;
    custom = true;
  } else if (data.extended_inventory) {
    inventory = [
      ...data.product_records,
      ...data.coin_records,
      ...data.hidden_records,
    ];
  } else {
    inventory = [
      ...data.product_records,
      ...data.coin_records,
    ];
  }
  return (
    <Fragment>
      {data.onstation && (
        <Section title="User">
          {data.user && (
            <Box>
            Welcome, <b>{data.user.name}</b>,
              {' '}
              <b>{data.user.job || "Unemployed"}</b>!
              <br />
            Your balance is <b>{data.user.cash} credits</b>.
            </Box>
          ) || (
            <Box color="light-gray">
            No registered ID card!<br />
            Please contact your local HoP!
            </Box>
          )}
        </Section>
      )}
      <Section title="Products" >
        <Table>
          {inventory.map((product => {
            const free = (
              !data.onstation
              || product.price === 0
              || (
                !product.premium
                && data.department
                && data.user
                && data.department === data.user.department
              )
            );
            return (
              <Table.Row key={product.name}>
                <Table.Cell>
                  {product.base64 ? (
                    <img
                      src={`data:image/jpeg;base64,${product.img}`}
                      style={{
                        'vertical-align': 'middle',
                        'horizontal-align': 'middle',
                      }} />
                  ) : (
                    <span
                      className={classes(['vending32x32', product.path])}
                      style={{
                        'vertical-align': 'middle',
                        'horizontal-align': 'middle',
                      }} />
                  )}
                  <b>{product.name}</b>
                </Table.Cell>
                <Table.Cell>
                  <Box color={custom
                    ? 'good'
                    : data.stock[product.name] <= 0
                      ? 'bad'
                      : data.stock[product.name] <= (product.max_amount / 2)
                        ? 'average'
                        : 'good'}>
                    {data.stock[product.name]} in stock
                  </Box>
                </Table.Cell>
                <Table.Cell>
                  {custom && (
                    <Button
                      content={data.access ? 'FREE' : product.price + ' cr'}
                      onClick={() => act(ref, 'dispense', {
                        'item': product.name,
                      })} />
                  ) || (
                    <Button
                      disabled={(
                        data.stock[product.namename] === 0
                        || (
                          !free
                          && (
                            !data.user
                            || product.price > data.user.cash
                          )
                        )
                      )}
                      content={free ? 'FREE' : product.price + ' cr'}
                      onClick={() => act(ref, 'vend', {
                        'ref': product.ref,
                      })} />
                  )}
                </Table.Cell>
              </Table.Row>
            );
          }))}
        </Table>
      </Section>
    </Fragment>
  );
};

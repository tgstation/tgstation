import { Fragment } from 'inferno';
import { act } from '../byond';
import { Section, Box, Button, Table } from '../components';
import { classes } from 'common/react';

export const MiningVendor = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  let inventory = [
    ...data.product_records,
  ];
  return (
    <Fragment>
      <Section title="User">
        {data.user && (
          <Box>
          Welcome, <b>{data.user.name || "Unknown"}</b>,
            {' '}
            <b>{data.user.job || "Unemployed"}</b>!
            <br />
          Your balance is <b>{data.user.points} mining points</b>.
          </Box>
        ) || (
          <Box color="light-gray">
          No registered ID card!<br />
          Please contact your local HoP!
          </Box>
        )}
      </Section>
      <Section title="Equipment" >
        <Table>
          {inventory.map((product => {
            return (
              <Table.Row key={product.name}>
                <Table.Cell>
                  <span
                    className={classes(['vending32x32', product.path])}
                    style={{
                      'vertical-align': 'middle',
                      'horizontal-align': 'middle',
                    }} />
                  {' '}<b>{product.name}</b>
                </Table.Cell>
                <Table.Cell>
                  <Button
                    style={{
                      'min-width': '95px',
                      'text-align': 'center',
                    }}
                    disabled={(!data.user || product.price > data.user.points)}
                    content={product.price + ' points'}
                    onClick={() => act(ref, 'purchase', {
                      'ref': product.ref,
                    })} />
                </Table.Cell>
              </Table.Row>
            );
          }))}
        </Table>
      </Section>
    </Fragment>
  );
};

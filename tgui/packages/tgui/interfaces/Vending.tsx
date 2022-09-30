import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

type VendingData = {
  onstation: boolean;
  department: string;
  jobDiscount: number;
  product_records: ProductRecord[];
  coin_records: CoinRecord[];
  hidden_records: HiddenRecord[];
  user: UserData;
  stock: StockItem[];
  extended_inventory: boolean;
  access: boolean;
  vending_machine_input: CustomInput[];
}

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
}

type CoinRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  premium: boolean;
}

type HiddenRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  premium: boolean;
}

type UserData = {
  name: string;
  cash: number;
  job: string;
  department: string;
}

type StockItem = {
  name: string;
  amount: number;
  colorable: boolean;
}

type CustomInput = {
  name: string;
  price: number;
  img: string;
}

const VendingRow = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const {
    product,
    productStock,
    custom,
  } = props;
  const {
    onstation,
    department,
    user,
    jobDiscount,
  } = data;
  const free = (
    !onstation
    || product.price === 0
    || (
      !product.premium
      && department
      && user
    )
  );
  const discount = department === user?.department;
  const redPrice = Math.round(product.price * jobDiscount);
  return (
    <Table.Row>
      <Table.Cell collapsing>
        {product.img && (
          <img
            src={`data:image/jpeg;base64,${product.img}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }} />
        ) || (
          <span
            className={classes([
              'vending32x32',
              product.path,
            ])}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }} />
        )}
      </Table.Cell>
      <Table.Cell bold>
        {product.name}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box
          color={(
            custom && 'good'
            || productStock.amount <= 0 && 'bad'
            || productStock.amount <= (product.max_amount / 2) && 'average'
            || 'good'
          )}>
          {custom ? product.amount : productStock.amount} in stock
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {custom && (
          <Button
            fluid
            content={data.access ? 'FREE' : product.price + ' cr'}
            onClick={() => act('dispense', {
              'item': product.name,
            })} />
        ) || (
          <Button
            fluid
            disabled={(
              productStock.amount === 0
              || !free && (
                !user
                || product.price > user.cash
              )
            )}
            content={(free && discount)
              ? `${redPrice} cr` : `${product.price} cr`}
            onClick={() => act('vend', {
              'ref': product.ref,
            })} />
        )}
      </Table.Cell>
      <Table.Cell>
        {
          productStock?.colorable
            ? (
              <Button
                fluid
                icon="palette"
                disabled={
                  productStock?.amount === 0
                  || (!free && (!user || product.price > user.cash))
                }
                onClick={() => act('select_colors', { ref: product.ref })}
              />
            )
            : ""
        }
      </Table.Cell>
    </Table.Row>
  );
};

export const Vending = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const {
    user,
    onstation,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    stock,
  } = data;
  let inventory;
  let custom = false;
  if (data.vending_machine_input) {
    inventory = data.vending_machine_input;
    custom = true;
  }
  else {
    inventory = [
      ...product_records,
      ...coin_records,
    ];
    if (data.extended_inventory) {
      inventory = [
        ...inventory,
        ...hidden_records,
      ];
    }
  }
  // Just in case we still have undefined values in the list
  inventory = inventory.filter(item => !!item);
  return (
    <Window
      width={450}
      height={600}>
      <Window.Content scrollable>
        {!!onstation && (
          <Section title="User">
            {user && (
              <Box>
                Welcome, <b>{user.name}</b>,
                {' '}
                <b>{user.job || 'Unemployed'}</b>!
                <br />
                Your balance is <b>{user.cash} credits</b>.
              </Box>
            ) || (
              <Box color="light-grey">
                No registered ID card!<br />
                Please contact your local HoP!
              </Box>
            )}
          </Section>
        )}
        <Section title="Products">
          <Table>
            {inventory.map(product => (
              <VendingRow
                key={product.name}
                custom={custom}
                product={product}
                productStock={stock[product.name]} />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

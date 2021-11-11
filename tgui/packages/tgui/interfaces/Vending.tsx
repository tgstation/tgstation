import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Icon, LabeledList, NoticeBox, Section, Stack, Table } from '../components';
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
};

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
};

type CoinRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  premium: boolean;
};

type HiddenRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  premium: boolean;
};

type UserData = {
  name: string;
  cash: number;
  job: string;
  department: string;
};

type StockItem = {
  name: string;
  amount: number;
  colorable: boolean;
};

type CustomInput = {
  name: string;
  price: number;
  img: string;
};

export const Vending = (props, context) => {
  return (
    <Window width={450} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <UserDetails />
          </Stack.Item>
          <Stack.Item grow>
            <ProductDisplay />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays user details if an ID is present and the user is on the station */
const UserDetails = (_, context) => {
  const { data } = useBackend<VendingData>(context);
  const { user, onstation } = data;

  if (!onstation) {
    return <NoticeBox>Error!</NoticeBox>;
  } else if (!user) {
    return (
      <NoticeBox>No ID detected! Contact the Head of Personnel.</NoticeBox>
    );
  } else {
    return (
      <Section>
        <Stack>
          <Stack.Item>
            <Icon name="id-card" size={3} mr={1} />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="User">{user.name}</LabeledList.Item>
              <LabeledList.Item label="Occupation">
                {user.job || 'Unemployed'}
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
};

/** Displays  products in a section, with user balance at top */
const ProductDisplay = (_, context) => {
  const { data } = useBackend<VendingData>(context);
  const {
    user,
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
  } else {
    inventory = [...product_records, ...coin_records];
    if (data.extended_inventory) {
      inventory = [...inventory, ...hidden_records];
    }
  }
  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);

  return (
    <Section
      fill
      scrollable
      title="Products"
      buttons={
        <Box fontSize="16px" color="green">
          {(user && user.cash) || 0} cr <Icon name="coins" color="gold" />
        </Box>
      }>
      <Table>
        {inventory.map((product) => (
          <VendingRow
            key={product.name}
            custom={custom}
            product={product}
            productStock={stock[product.name]}
          />
        ))}
      </Table>
    </Section>
  );
};

/** An individual listing for an item.
 * Uses a table layout - Labeledlist might be better,
 * but you cannot use item icons as labels currently.
 */
const VendingRow = (props, context) => {
  const { data } = useBackend<VendingData>(context);
  const { custom, product, productStock } = props;
  const { department, onstation, user } = data;
  const free
    = !onstation
    || product.price === 0
    || (!product.premium && department && user);

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <ProductImage product={product} />
      </Table.Cell>
      <Table.Cell bold>
        {product.name.replace(/^\w/, (c) => c.toUpperCase())}
      </Table.Cell>
      <Table.Cell>
        {!!productStock?.colorable && (
          <ProductColorSelect free={free} product={product} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <ProductStock
          custom={custom}
          product={product}
          productStock={productStock}
        />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <ProductButton
          free={free}
          product={product}
          productStock={productStock}
        />
      </Table.Cell>
    </Table.Row>
  );
};

/** Displays the product image. Displays a default if there is none. */
const ProductImage = (props) => {
  const { product } = props;

  return product.img ? (
    <img
      src={`data:image/jpeg;base64,${product.img}`}
      style={{
        'vertical-align': 'middle',
        'horizontal-align': 'middle',
      }}
    />
  ) : (
    <span
      className={classes(['vending32x32', product.path])}
      style={{
        'vertical-align': 'middle',
        'horizontal-align': 'middle',
      }}
    />
  );
};

/** Displays a colored indicator for remaining stock */
const ProductStock = (props) => {
  const { custom, product, productStock } = props;

  return (
    <Box
      color={
        (custom && 'good')
        || (productStock.amount <= 0 && 'bad')
        || (productStock.amount <= product.max_amount / 2 && 'average')
        || 'good'
      }>
      {custom ? product.amount : productStock.amount} left
    </Box>
  );
};

/** In the case of customizable items, ie: shoes,
 * this displays a color wheel button that opens another window.
 */
const ProductColorSelect = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { user } = data;
  const { product, productStock } = props;

  return (
    <Button
      icon="palette"
      tooltip="Change color"
      disabled={
        productStock?.amount === 0
        || (!user || product.price > user.cash)
      }
      onClick={() => act('select_colors', { ref: product.ref })}
    />
  );
};

/** The main button to purchase an item. */
const ProductButton = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { access, department, jobDiscount, user } = data;
  const { custom, free, product, productStock } = props;
  const discount = department === user?.department;
  const redPrice = Math.round(product.price * jobDiscount);

  return custom ? (
    <Button
      fluid
      disabled={
        productStock.amount === 0
        || (!user || product.price > user.cash)
      }
      content={access ? 'FREE' : product.price + ' cr'}
      onClick={() =>
        act('dispense', {
          'item': product.name,
        })}
    />
  ) : (
    <Button
      fluid
      disabled={
        productStock.amount === 0
        || (!user || product.price > user.cash)
      }
      content={free && discount ? `${redPrice} cr` : `${product.price} cr`}
      onClick={() =>
        act('vend', {
          'ref': product.ref,
        })}
    />
  );
};

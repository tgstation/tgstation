import { useState } from 'react';
import {
  Button,
  Icon,
  ImageButton,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeAll, createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { getLayoutState, LAYOUT, LayoutToggle } from './common/LayoutToggle';

type VendingData = {
  all_products_free: boolean;
  onstation: boolean;
  department: string;
  jobDiscount: number;
  displayed_currency_icon: string;
  displayed_currency_name: string;
  product_records: ProductRecord[];
  coin_records: CoinRecord[];
  hidden_records: HiddenRecord[];
  user: UserData;
  stock: Record<string, StockItem>[];
  extended_inventory: boolean;
  access: boolean;
  vending_machine_input: CustomInput[];
  categories: Record<string, Category>;
};

type Category = {
  icon: string;
};

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  category: string;
  icon?: string;
  icon_state?: string;
};

type CoinRecord = ProductRecord & {
  premium: boolean;
};

type HiddenRecord = ProductRecord & {
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
  path: string;
  amount: number;
  colorable: boolean;
};

type CustomInput = {
  path: string;
  name: string;
  price: number;
  img: string;
};

export const Vending = (props) => {
  const { data } = useBackend<VendingData>();

  const {
    onstation,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    categories,
  } = data;

  const [selectedCategory, setSelectedCategory] = useState(
    Object.keys(categories)[0],
  );

  const [stockSearch, setStockSearch] = useState('');
  const stockSearchFn = createSearch(
    stockSearch,
    (item: ProductRecord | CustomInput) => item.name,
  );

  let inventory: (ProductRecord | CustomInput)[];
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

  if (stockSearch.length >= 2) {
    inventory = inventory.filter(stockSearchFn);
  }

  const filteredCategories = Object.fromEntries(
    Object.entries(data.categories).filter(([categoryName]) => {
      return inventory.find((product) => {
        if ('category' in product) {
          return product.category === categoryName;
        } else {
          return false;
        }
      });
    }),
  );

  return (
    <Window width={431} height={635}>
      <Window.Content>
        <Stack fill vertical>
          {!!onstation && (
            <Stack.Item>
              <UserDetails />
            </Stack.Item>
          )}
          <Stack.Item grow>
            <ProductDisplay
              custom={custom}
              inventory={inventory}
              stockSearch={stockSearch}
              setStockSearch={setStockSearch}
              selectedCategory={selectedCategory}
              setSelectedCategory={setSelectedCategory}
            />
          </Stack.Item>

          {stockSearch.length < 2 &&
            Object.keys(filteredCategories).length > 1 && (
              <Stack.Item>
                <CategorySelector
                  categories={filteredCategories}
                  selectedCategory={selectedCategory!}
                  onSelect={setSelectedCategory}
                />
              </Stack.Item>
            )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays user details if an ID is present and the user is on the station */
export const UserDetails = (props) => {
  const { data } = useBackend<VendingData>();
  const { user } = data;

  return (
    <NoticeBox m={0} color={user && 'blue'}>
      <Stack align="center">
        <Stack.Item>
          <Icon name="id-card" size={1.5} />
        </Stack.Item>
        <Stack.Item>
          {user
            ? `${user.name || 'Unknown'} | ${user.job}`
            : 'No ID detected! Contact the Head of Personnel.'}
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};

/** Displays  products in a section, with user balance at top */
const ProductDisplay = (props: {
  custom: boolean;
  inventory: (ProductRecord | CustomInput)[];
  stockSearch: string;
  setStockSearch: (search: string) => void;
  selectedCategory: string | null;
  setSelectedCategory: (category: string) => void;
}) => {
  const { data } = useBackend<VendingData>();
  const {
    custom,
    inventory,
    stockSearch,
    setStockSearch,
    selectedCategory,
    setSelectedCategory,
  } = props;
  const {
    stock,
    all_products_free,
    user,
    displayed_currency_icon,
    displayed_currency_name,
  } = data;
  const [toggleLayout, setToggleLayout] = useState(getLayoutState(LAYOUT.Grid));

  return (
    <Section
      fill
      scrollable
      title="Products"
      buttons={
        <Stack>
          {!all_products_free && user && (
            <Stack.Item fontSize="16px" color="green">
              {(user && user.cash) || 0}
              {displayed_currency_name}
              <Icon name={displayed_currency_icon} color="gold" />
            </Stack.Item>
          )}
          <Stack.Item>
            <Input
              onInput={(_, value) => setStockSearch(value)}
              placeholder="Search..."
              value={stockSearch}
            />
          </Stack.Item>
          <LayoutToggle state={toggleLayout} setState={setToggleLayout} />
        </Stack>
      }
    >
      {inventory
        .filter((product) => {
          if (!stockSearch && 'category' in product) {
            return product.category === selectedCategory;
          } else {
            return true;
          }
        })
        .map((product) => (
          <Product
            key={product.path}
            fluid={toggleLayout === LAYOUT.List}
            custom={custom}
            product={product}
            productStock={stock[product.path]}
          />
        ))}
    </Section>
  );
};

/**
 * An individual listing for an item.
 */
const Product = (props) => {
  const { act, data } = useBackend<VendingData>();
  const { custom, product, productStock, fluid } = props;
  const { access, department, jobDiscount, all_products_free, user } = data;

  const colorable = !!productStock?.colorable;
  const free = all_products_free || product.price === 0;
  const discount = !product.premium && department === user?.department;
  const remaining = custom ? product.amount : productStock.amount;
  const redPrice = Math.round(product.price * jobDiscount);
  const disabled =
    remaining === 0 ||
    (!all_products_free && !user) ||
    (!all_products_free &&
      !access &&
      (discount ? redPrice : product.price) > user?.cash);

  const baseProps = {
    base64: product.image,
    dmIcon: product.icon,
    dmIconState: product.icon_state,
    asset: ['vending32x32', product.path],
    disabled: disabled,
    tooltipPosition: 'bottom',
    buttons: colorable && (
      <ProductColorSelect disabled={disabled} product={product} fluid={fluid} />
    ),
    product: product,
    colorable: colorable,
    remaining: remaining,
    onClick: () => {
      custom
        ? act('dispense', {
            item: product.path,
          })
        : act('vend', {
            ref: product.ref,
            discountless: !!product.premium,
          });
    },
  };

  const priceProps = {
    custom: custom,
    discount: discount,
    free: free,
    product: product,
    redPrice: redPrice,
  };

  return fluid ? (
    <ProductList {...baseProps} {...priceProps} />
  ) : (
    <ProductGrid {...baseProps} {...priceProps} />
  );
};

const ProductGrid = (props) => {
  const { product, remaining, ...baseProps } = props;
  const { ...priceProps } = props;

  return (
    <ImageButton
      {...baseProps}
      tooltip={capitalizeAll(product.name)}
      buttonsAlt={
        <Stack fontSize={0.8}>
          <Stack.Item grow textAlign={'left'}>
            <ProductPrice {...priceProps} />
          </Stack.Item>
          <Stack.Item color={'lightgray'}>x{remaining}</Stack.Item>
        </Stack>
      }
    >
      {capitalizeAll(product.name)}
    </ImageButton>
  );
};

const ProductList = (props) => {
  const { colorable, product, remaining, ...baseProps } = props;
  const { ...priceProps } = props;

  return (
    <ImageButton {...baseProps} fluid imageSize={32}>
      <Stack textAlign={'right'} align="center">
        <Stack.Item grow textAlign={'left'}>
          {capitalizeAll(product.name)}
        </Stack.Item>
        <Stack.Item
          width={3.5}
          fontSize={0.8}
          color={'rgba(255, 255, 255, 0.5)'}
        >
          {remaining} left
        </Stack.Item>
        <Stack.Item
          width={3.5}
          style={{ marginRight: !colorable ? '32px' : '' }}
        >
          <ProductPrice {...priceProps} />
        </Stack.Item>
      </Stack>
    </ImageButton>
  );
};

/**
 * In the case of customizable items, ie: shoes,
 * this displays a color wheel button that opens another window.
 */
const ProductColorSelect = (props) => {
  const { act } = useBackend<VendingData>();
  const { disabled, product, fluid } = props;

  return (
    <Button
      width={fluid ? '32px' : '20px'}
      icon={'palette'}
      color={'transparent'}
      tooltip={'Change color'}
      style={disabled && { pointerEvents: 'none', opacity: 0.5 }}
      onClick={() => act('select_colors', { ref: product.ref })}
    />
  );
};

/** The main button to purchase an item. */
const ProductPrice = (props) => {
  const { act, data } = useBackend<VendingData>();
  const { access, displayed_currency_name } = data;
  const { custom, discount, free, product, redPrice } = props;
  const customPrice = access ? 'Free' : product.price;
  let standardPrice = product.price;
  if (free) {
    standardPrice = 'Free';
  } else if (discount) {
    standardPrice = redPrice;
  }
  return (
    <Stack.Item fontSize={0.85} color={'gold'}>
      {custom ? (
        <>
          {customPrice}
          {!access && displayed_currency_name}
        </>
      ) : (
        <>
          {standardPrice}
          {!free && displayed_currency_name}
        </>
      )}
    </Stack.Item>
  );
};

const CATEGORY_COLORS = {
  Contraband: 'red',
  Premium: 'yellow',
};

const CategorySelector = (props: {
  categories: Record<string, Category>;
  selectedCategory: string;
  onSelect: (category: string) => void;
}) => {
  const { categories, selectedCategory, onSelect } = props;

  return (
    <Section>
      {Object.entries(categories).map(([name, category]) => (
        <Button
          key={name}
          selected={name === selectedCategory}
          color={CATEGORY_COLORS[name]}
          icon={category.icon}
          onClick={() => onSelect(name)}
        >
          {name}
        </Button>
      ))}
    </Section>
  );
};

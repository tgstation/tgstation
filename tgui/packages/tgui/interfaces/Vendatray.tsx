import { Box, Button, Image, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  product_name: string;
  registered: BooleanLike;
  owner_name: string;
  product_cost: number;
  tray_open: BooleanLike;
  product_icon: string;
};

export const Vendatray = (props) => {
  const { act, data } = useBackend<Data>();
  const { product_name, registered, owner_name } = data;

  return (
    <Window width={300} height={270}>
      <Window.Content>
        <Stack>
          <Stack.Item>{!!product_name && <VendingImage />}</Stack.Item>
          <Stack.Item grow>
            <ProductInfo />
          </Stack.Item>
        </Stack>
        {registered ? (
          <Section italic>Pays to the account of {owner_name}.</Section>
        ) : (
          <>
            <Section>Tray is unregistered.</Section>
            <Button
              fluid
              icon="cash-register"
              content="Register Tray"
              disabled={registered}
              onClick={() => act('Register')}
            />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

/** Lists product info and buttons to open or purchase */
const ProductInfo = (props) => {
  const { act, data } = useBackend<Data>();
  const { product_name, product_cost, tray_open } = data;

  return (
    <>
      <Section fontSize="18px" align="center">
        <b>{product_name ? product_name : 'Empty'}</b>
        <Box fontSize="16px">
          <i>{product_name ? product_cost : 'N/A'} cr </i>
          <Button icon="pen" onClick={() => act('Adjust')} />
        </Box>
      </Section>
      <>
        <Button
          fluid
          icon="window-restore"
          content={tray_open ? 'Open' : 'Closed'}
          selected={tray_open}
          onClick={() => act('Open')}
        />
        <Button.Confirm
          fluid
          icon="money-bill-wave"
          content="Purchase Item"
          disabled={!product_name}
          onClick={() => act('Buy')}
        />
      </>
    </>
  );
};

/** Produces an image from the product icon */
const VendingImage = (props) => {
  const { data } = useBackend<Data>();
  const { product_icon } = data;

  return (
    <Section height="100%">
      <Image
        m={1}
        src={`data:image/jpeg;base64,${product_icon}`}
        height="96px"
        width="96px"
        style={{
          verticalAlign: 'middle',
        }}
      />
    </Section>
  );
};

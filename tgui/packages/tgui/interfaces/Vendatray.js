import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Button, LabeledList, Section, Flex, Box } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const Vendatray = (props, context) => {
  const { act, data } = useBackend(context);
  const locked = data.locked && !data.siliconUser;
  const {
    product_name,
    product_cost,
    tray_open,
    registered,
    owner_name,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Flex
          mb={1}>
          <Flex.Item
            mr={1}>
            <Section
              maxWidth="150px"
              fontSize="20px">
              <b>{product_name ? product_name : "Empty"}</b>
            </Section>
            <Section
              minWidth="100px"
              minHeight="45px"
              align="center">
              <Box fontSize="20px">
                Price:
              </Box>
              <i>{product_name ? product_cost : "N/A"} Cr</i>
            </Section>
          </Flex.Item>
          <Flex.Item>
            {!!product_name && (
              <VendingImage />
            )}
          </Flex.Item>
        </Flex>
        {registered?(
          <Section italics>
            <Box m={0.5}>
              Pays to the account of {owner_name}.
            </Box>
            <Fragment>
              <Button
                fluid
                icon="window-restore"
                content={tray_open ? 'Open' : 'Closed'}
                selected={tray_open}
                onClick={() => act('Open')} />
              <Button.Confirm
                fluid
                icon="money-bill-wave"
                content="Purchase Item"
                disabled={!product_name}
                onClick={() => act('Buy')} />
              <Button
                fluid
                icon="pen"
                content="Change Cost"
                onClick={() => act('Adjust')} />
            </Fragment>
          </Section>
        ):(
          <Fragment>
            <Section>
              Tray is unregistered.
            </Section>
            <Button
              fluid
              icon="cash-register"
              content="Register Tray"
              disabled={registered}
              onClick={() => act('Register')} />
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};

const VendingImage = (props, context) => {
  const { data } = useBackend(context);
  const {
    product_icon,
  } = data;
  return (
    <Section m={1}>
      <img
        src={`data:image/jpeg;base64,${product_icon}`}
        height="96"
        width="96"
        align="center"
        style={{
          '-ms-interpolation-mode': 'nearest-neighbor',
          'vertical-align': 'middle',
          'horizontal-align': 'middle',
        }} />
    </Section>
  );
};

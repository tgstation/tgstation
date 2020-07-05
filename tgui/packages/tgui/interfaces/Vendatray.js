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
          <Flex.Item>
            {!!product_name && (
              <VendingImage />
            )}
          </Flex.Item>
          <Flex.Item
            mr={1}>
            <Section
              maxWidth="150px"
              fontSize="18px"
              align="center">
              <b>{product_name ? product_name : "Empty"}</b>
              <Box fontSize="16px">
                <i>{product_name ? product_cost : "N/A"} cr </i>
                <Button
                  icon="pen"
                  onClick={() => act('Adjust')} />
              </Box>
            </Section>
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
            </Fragment>
          </Flex.Item>
        </Flex>
        {registered?(
          <Section italics>
            Pays to the account of {owner_name}.
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

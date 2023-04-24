import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Grid, Section, Table, Tooltip } from '../components';
import { Window } from '../layouts';

export const ComputerFabricator = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window title="Personal Computer Vendor" width={500} height={400}>
      <Window.Content>
        <Section italic fontSize="20px">
          Your perfect device, only three steps away...
        </Section>
        {data.state !== 0 && (
          <Button
            fluid
            mb={1}
            icon="circle"
            content="Clear Order"
            onClick={() => act('clean_order')}
          />
        )}
        {data.state === 0 && <CfStep1 />}
        {data.state === 1 && <CfStep2 />}
        {data.state === 2 && <CfStep3 />}
        {data.state === 3 && <CfStep4 />}
      </Window.Content>
    </Window>
  );
};

// This had a pretty gross backend so this was unfortunately one of the
// best ways of doing it.
const CfStep1 = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Step 1" minHeight="306px">
      <Box mt={5} bold textAlign="center" fontSize="40px">
        Choose your Device
      </Box>
      <Box mt={3}>
        <Grid width="100%">
          <Grid.Column>
            <Button
              fluid
              icon="laptop"
              content="Laptop"
              textAlign="center"
              fontSize="30px"
              lineHeight={2}
              onClick={() =>
                act('pick_device', {
                  pick: '1',
                })
              }
            />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              icon="tablet-alt"
              content="Tablet"
              textAlign="center"
              fontSize="30px"
              lineHeight={2}
              onClick={() =>
                act('pick_device', {
                  pick: '2',
                })
              }
            />
          </Grid.Column>
        </Grid>
      </Box>
    </Section>
  );
};

const CfStep2 = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Step 2: Customize your device"
      minHeight="282px"
      buttons={
        <Box bold color="good">
          {data.totalprice} cr
        </Box>
      }>
      <Table>
        <Table.Row>
          <Table.Cell bold position="relative">
            <Tooltip
              content={multiline`
                Stores file on your device. Advanced drives can store more
                files, but use more power, shortening battery life.
              `}
              position="right">
              Hard Drive:
            </Tooltip>
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_disk === 1}
              onClick={() =>
                act('hw_disk', {
                  disk: '1',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Upgraded"
              selected={data.hw_disk === 2}
              onClick={() =>
                act('hw_disk', {
                  disk: '2',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Advanced"
              selected={data.hw_disk === 3}
              onClick={() =>
                act('hw_disk', {
                  disk: '3',
                })
              }
            />
          </Table.Cell>
        </Table.Row>
      </Table>
      <Button
        fluid
        mt={3}
        content="Confirm Order"
        color="good"
        textAlign="center"
        fontSize="18px"
        lineHeight={2}
        onClick={() => act('confirm_order')}
      />
    </Section>
  );
};

const CfStep3 = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Step 3: Payment" minHeight="282px">
      <Box italic textAlign="center" fontSize="20px">
        Your device is ready for fabrication...
      </Box>
      <Box bold mt={2} textAlign="center" fontSize="16px">
        <Box inline>Please insert the required</Box>{' '}
        <Box inline color="good">
          {data.totalprice} cr
        </Box>
      </Box>
      <Box bold mt={1} textAlign="center" fontSize="18px">
        Current:
      </Box>
      <Box
        bold
        mt={0.5}
        textAlign="center"
        fontSize="18px"
        color={data.credits >= data.totalprice ? 'good' : 'bad'}>
        {data.credits} cr
      </Box>
      <Button
        fluid
        content="Purchase"
        disabled={data.credits < data.totalprice}
        mt={8}
        color="good"
        textAlign="center"
        fontSize="20px"
        lineHeight={2}
        onClick={() => act('purchase')}
      />
    </Section>
  );
};

const CfStep4 = (props, context) => {
  return (
    <Section minHeight="282px">
      <Box bold textAlign="center" fontSize="28px" mt={10}>
        Thank you for your purchase!
      </Box>
      <Box italic mt={1} textAlign="center">
        If you experience any difficulties with your new device, please contact
        your local network administrator.
      </Box>
    </Section>
  );
};

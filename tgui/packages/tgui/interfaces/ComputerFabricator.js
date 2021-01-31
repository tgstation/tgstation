import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Grid, Section, Table, Tooltip } from '../components';
import { Window } from '../layouts';

export const ComputerFabricator = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Personal Computer Vendor"
      width={500}
      height={400}
      resizable>
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
            onClick={() => act('clean_order')} />
        )}
        {data.state === 0 && (
          <CfStep1 />
        )}
        {data.state === 1 && (
          <CfStep2 />
        )}
        {data.state === 2 && (
          <CfStep3 />
        )}
        {data.state === 3 && (
          <CfStep4 />
        )}
      </Window.Content>
    </Window>
  );
};

// This had a pretty gross backend so this was unfortunately one of the
// best ways of doing it.
const CfStep1 = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Step 1"
      minHeight="306px">
      <Box
        mt={5}
        bold
        textAlign="center"
        fontSize="40px">
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
              onClick={() => act('pick_device', {
                pick: '1',
              })} />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              icon="tablet-alt"
              content="Tablet"
              textAlign="center"
              fontSize="30px"
              lineHeight={2}
              onClick={() => act('pick_device', {
                pick: '2',
              })} />
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
      buttons={(
        <Box bold color="good">
          {data.totalprice} cr
        </Box>
      )}>
      <Table>
        <Table.Row>
          <Table.Cell
            bold
            position="relative">
            Battery:
            <Tooltip
              content={multiline`
                Allows your device to operate without external utility power
                source. Advanced batteries increase battery life.
              `}
              position="right" />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_battery === 1}
              onClick={() => act('hw_battery', {
                battery: '1',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Upgraded"
              selected={data.hw_battery === 2}
              onClick={() => act('hw_battery', {
                battery: '2',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Advanced"
              selected={data.hw_battery === 3}
              onClick={() => act('hw_battery', {
                battery: '3',
              })} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell
            bold
            position="relative">
            Hard Drive:
            <Tooltip
              content={multiline`
                Stores file on your device. Advanced drives can store more
                files, but use more power, shortening battery life.
              `}
              position="right" />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_disk === 1}
              onClick={() => act('hw_disk', {
                disk: '1',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Upgraded"
              selected={data.hw_disk === 2}
              onClick={() => act('hw_disk', {
                disk: '2',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Advanced"
              selected={data.hw_disk === 3}
              onClick={() => act('hw_disk', {
                disk: '3',
              })} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold position="relative">
            Network Card:
            <Tooltip
              content={multiline`
                Allows your device to wirelessly connect to stationwide NTNet
                network. Basic cards are limited to on-station use, while
                advanced cards can operate anywhere near the station, which
                includes asteroid outposts
              `}
              position="right" />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="None"
              selected={data.hw_netcard === 0}
              onClick={() => act('hw_netcard', {
                netcard: '0',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_netcard === 1}
              onClick={() => act('hw_netcard', {
                netcard: '1',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Advanced"
              selected={data.hw_netcard === 2}
              onClick={() => act('hw_netcard', {
                netcard: '2',
              })} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold position="relative">
            Nano Printer:
            <Tooltip
              content={multiline`
                A device that allows for various paperwork manipulations,
                such as, scanning of documents or printing new ones.
                This device was certified EcoFriendlyPlus and is capable of
                recycling existing paper for printing purposes.
              `}
              position="right" />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="None"
              selected={data.hw_nanoprint === 0}
              onClick={() => act('hw_nanoprint', {
                print: '0',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_nanoprint === 1}
              onClick={() => act('hw_nanoprint', {
                print: '1',
              })} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold position="relative">
            Secondary Card Reader:
            <Tooltip
              content={multiline`
                Adds a secondary RFID card reader, for manipulating or
                reading from a second standard RFID card.
                Please note that a primary card reader is necessary to
                allow the device to read your identification, but one
                is included in the base price.
              `}
              position="right" />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="None"
              selected={data.hw_card === 0}
              onClick={() => act('hw_card', {
                card: '0',
              })} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_card === 1}
              onClick={() => act('hw_card', {
                card: '1',
              })} />
          </Table.Cell>
        </Table.Row>
        {data.devtype !== 2 && (
          <>
            <Table.Row>
              <Table.Cell bold position="relative">
                Processor Unit:
                <Tooltip
                  content={multiline`
                    A component critical for your device's functionality.
                    It allows you to run programs from your hard drive.
                    Advanced CPUs use more power, but allow you to run
                    more programs on background at once.
                  `}
                  position="right" />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Standard"
                  selected={data.hw_cpu === 1}
                  onClick={() => act('hw_cpu', {
                    cpu: '1',
                  })} />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Advanced"
                  selected={data.hw_cpu === 2}
                  onClick={() => act('hw_cpu', {
                    cpu: '2',
                  })} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold position="relative">
                Tesla Relay:
                <Tooltip
                  content={multiline`
                    An advanced wireless power relay that allows your device
                    to connect to nearby area power controller to provide
                    alternative power source. This component is currently
                    unavailable on tablet computers due to size restrictions.
                  `}
                  position="right" />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="None"
                  selected={data.hw_tesla === 0}
                  onClick={() => act('hw_tesla', {
                    tesla: '0',
                  })} />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Standard"
                  selected={data.hw_tesla === 1}
                  onClick={() => act('hw_tesla', {
                    tesla: '1',
                  })} />
              </Table.Cell>
            </Table.Row>
          </>
        )}
      </Table>
      <Button
        fluid
        mt={3}
        content="Confirm Order"
        color="good"
        textAlign="center"
        fontSize="18px"
        lineHeight={2}
        onClick={() => act('confirm_order')} />
    </Section>
  );
};

const CfStep3 = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Step 3: Payment"
      minHeight="282px">
      <Box
        italic
        textAlign="center"
        fontSize="20px">
        Your device is ready for fabrication...
      </Box>
      <Box
        bold
        mt={2}
        textAlign="center"
        fontSize="16px">
        <Box inline>
          Please insert the required
        </Box>
        {' '}
        <Box inline color="good">
          {data.totalprice} cr
        </Box>
      </Box>
      <Box
        bold
        mt={1}
        textAlign="center"
        fontSize="18px">
        Current:
      </Box>
      <Box
        bold
        mt={0.5}
        textAlign="center"
        fontSize="18px"
        color={data.credits >= data.totalprice ? "good" : "bad"}>
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
        onClick={() => act('purchase')} />
    </Section>
  );
};

const CfStep4 = (props, context) => {
  return (
    <Section
      minHeight="282px">
      <Box
        bold
        textAlign="center"
        fontSize="28px"
        mt={10}>
        Thank you for your purchase!
      </Box>
      <Box
        italic
        mt={1}
        textAlign="center">
        If you experience any difficulties with your new device, please
        contact your local network administrator.
      </Box>
    </Section>
  );
};

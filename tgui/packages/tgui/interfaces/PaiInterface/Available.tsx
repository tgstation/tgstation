import { useBackend } from 'tgui/backend';
import { Box, Button, Icon, ProgressBar, Section, Table, Tooltip } from 'tgui/components';
import { SOFTWARE_DESC } from './constants';
import { Data } from './types';

/**
 * Renders a list of available software and the ram with which to download it
 */
export const AvailableDisplay = () => {
  return (
    <Section
      buttons={<MemoryDisplay />}
      fill
      scrollable
      title="Available Software">
      <SoftwareList />
    </Section>
  );
};

/** Displays the remaining RAM left as a progressbar. */
const MemoryDisplay = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { ram } = data;

  return (
    <Tooltip content={`Available System Memory: ${ram}`}>
      <Table>
        <Table.Row>
          <Table.Cell>
            <Icon color="purple" mt={0.7} name="microchip" />
          </Table.Cell>
          <Table.Cell>
            <ProgressBar
              minValue={0}
              maxValue={100}
              ranges={{
                good: [67, 100],
                average: [34, 66],
                bad: [0, 33],
              }}
              value={ram}
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Tooltip>
  );
};

/** A list of available software.
 *  creates table rows for each, like a vendor.
 */
const SoftwareList = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { available } = data;
  if (!available) {
    return null;
  }
  const entries = Object.entries(available);
  if (entries.length === 0) {
    return null;
  }

  return (
    <Table>
      {entries?.map(([name, cost], index) => {
        return <ListItem cost={cost} key={index} name={name} />;
      })}
    </Table>
  );
};

/** A row for an individual software listing. */
const ListItem = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { installed, ram } = data;
  const { cost, name } = props;
  const purchased = installed.includes(name);

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsible>
        <Box color="label">{name}</Box>
      </Table.Cell>
      <Table.Cell collapsible>
        <Box color={ram < cost && 'bad'} textAlign="right">
          {!purchased && cost}{' '}
          <Icon
            color={purchased || ram >= cost ? 'purple' : 'bad'}
            name={purchased ? 'check' : 'microchip'}
          />
        </Box>
      </Table.Cell>
      <Table.Cell collapsible>
        <Button
          fluid
          mb={0.5}
          disabled={ram < cost || purchased}
          onClick={() => act('buy', { selection: name })}
          tooltip={SOFTWARE_DESC[name]}
          tooltipPosition="bottom-start">
          <Icon ml={1} mr={-2} name="download" />
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

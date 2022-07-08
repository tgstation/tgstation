import { capitalize } from 'common/string';
import { useBackend } from 'tgui/backend';
import { Box, Button, Icon, ProgressBar, Section, Table, Tooltip } from 'tgui/components';
import { SOFTWARE_DESC } from '../constants';
import { Available, Data } from '../types';

/**
 * Renders a list of available software and the ram with which to download it
 */
export const AvailableDisplay = () => {
  return (
    <Section
      buttons={<AvailableMemory />}
      fill
      scrollable
      title="Available Software">
      <AvailableSoftware />
    </Section>
  );
};

/** Displays the remaining RAM left as a progressbar. */
const AvailableMemory = (props, context) => {
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
const AvailableSoftware = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { available } = data;
  const convertedList: Available[] = Object.entries(available).map((key) => {
    return { name: key[0], value: key[1] };
  });

  return (
    <Table>
      {convertedList?.map((software, index) => {
        return <AvailableRow key={index} software={software} />;
      })}
    </Table>
  );
};

/** A row for an individual software listing. */
const AvailableRow = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { ram } = data;
  const { installed } = data;
  const { software } = props;
  const purchased = installed.includes(software.name);

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsible>
        <Box color="label">{capitalize(software)}</Box>
      </Table.Cell>
      <Table.Cell collapsible>
        <Box color={ram < software.value && 'bad'} textAlign="right">
          {!purchased && software.value}{' '}
          <Icon
            color={purchased || ram >= software.value ? 'purple' : 'bad'}
            name={purchased ? 'check' : 'microchip'}
          />
        </Box>
      </Table.Cell>
      <Table.Cell collapsible>
        <Button
          fluid
          mb={0.5}
          disabled={ram < software.value || purchased}
          onClick={() => act('buy', { selection: software.name })}
          tooltip={SOFTWARE_DESC[software.name] || ''}
          tooltipPosition="bottom-start">
          <Icon ml={1} mr={-2} name="download" />
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

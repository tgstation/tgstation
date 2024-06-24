import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Icon,
  ProgressBar,
  Section,
  Table,
  Tooltip,
} from 'tgui/components';

import { SOFTWARE_DESC } from './constants';
import { PaiData } from './types';

/**
 * Renders a list of available software and the ram with which to download it
 */
export function AvailableDisplay(props) {
  const { data } = useBackend<PaiData>();
  const { available } = data;

  const entries = Object.entries(available);
  if (entries.length === 0) {
    return null;
  }

  return (
    <Section
      buttons={<MemoryDisplay />}
      fill
      scrollable
      title="Available Software"
    >
      <Table>
        {entries?.map(([name, cost]) => {
          return <ListItem cost={cost} key={name} name={name} />;
        })}
      </Table>
    </Section>
  );
}

/** Displays the remaining RAM left as a progressbar. */
function MemoryDisplay(props) {
  const { data } = useBackend<PaiData>();
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
              width={5}
            >
              {ram}
            </ProgressBar>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Tooltip>
  );
}

type ListItemProps = {
  cost: number;
  name: string;
};

/** A row for an individual software listing. */
function ListItem(props: ListItemProps) {
  const { act, data } = useBackend<PaiData>();
  const { installed, ram } = data;
  const { cost, name } = props;

  const purchased = installed.includes(name);
  const tooExpensive = ram < cost;

  return (
    <Tooltip content={SOFTWARE_DESC[name]} position="bottom-start">
      <Table.Row className="candystripe">
        <Table.Cell>
          <Box color="label">{name}</Box>
        </Table.Cell>
        <Table.Cell collapsing>
          <Box color={tooExpensive && 'bad'} textAlign="right">
            {!purchased && cost}{' '}
            <Icon
              color={purchased || ram >= cost ? 'purple' : 'bad'}
              name={purchased ? 'check' : 'microchip'}
            />
          </Box>
        </Table.Cell>
        <Table.Cell collapsing>
          <Button
            icon="download"
            mb={0.5}
            disabled={tooExpensive || purchased}
            onClick={() => act('buy', { selection: name })}
          />
        </Table.Cell>
      </Table.Row>
    </Tooltip>
  );
}

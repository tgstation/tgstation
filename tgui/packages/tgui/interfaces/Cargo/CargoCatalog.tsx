import { useMemo } from 'react';

import { useBackend, useSharedState } from '../../backend';
import {
  Button,
  Flex,
  Icon,
  Input,
  Section,
  Stack,
  Table,
  Tabs,
} from '../../components';
import { formatMoney } from '../../format';
import { CargoCartButtons } from './CargoButtons';
import { searchForSupplies } from './helpers';
import { CargoData } from './types';

export function CargoCatalog(props) {
  const { express } = props;
  const { act, data } = useBackend<CargoData>();
  const { self_paid, app_cost } = data;

  const supplies = Object.values(data.supplies);

  const { amount_by_name = [], max_order } = data;

  const [activeSupplyName, setActiveSupplyName] = useSharedState(
    'supply',
    supplies[0]?.name,
  );

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const activeSupply = useMemo(() => {
    return activeSupplyName === 'search_results'
      ? { packs: searchForSupplies(supplies, searchText) }
      : supplies.find((supply) => supply.name === activeSupplyName);
  }, [activeSupplyName, supplies, searchText]);

  return (
    <Section
      title="Catalog"
      buttons={
        !express && (
          <>
            <CargoCartButtons />
            <Button.Checkbox
              ml={2}
              checked={self_paid}
              onClick={() => act('toggleprivate')}
            >
              Buy Privately
            </Button.Checkbox>
          </>
        )
      }
    >
      <Flex>
        <Flex.Item ml={-1} mr={1}>
          <Tabs vertical>
            <Tabs.Tab
              key="search_results"
              selected={activeSupplyName === 'search_results'}
            >
              <Stack align="baseline">
                <Stack.Item>
                  <Icon name="search" />
                </Stack.Item>
                <Stack.Item grow>
                  <Input
                    fluid
                    placeholder="Search..."
                    value={searchText}
                    onInput={(e, value) => {
                      if (value === searchText) {
                        return;
                      }

                      if (value.length) {
                        // Start showing results
                        setActiveSupplyName('search_results');
                      } else if (activeSupplyName === 'search_results') {
                        // return to normal category
                        setActiveSupplyName(supplies[0]?.name);
                      }
                      setSearchText(value);
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Tabs.Tab>
            {supplies.map((supply) => (
              <Tabs.Tab
                key={supply.name}
                selected={supply.name === activeSupplyName}
                onClick={() => {
                  setActiveSupplyName(supply.name);
                  setSearchText('');
                }}
              >
                {supply.name} ({supply.packs.length})
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          <Table>
            {activeSupply?.packs.map((pack) => {
              const tags: string[] = [];
              if (pack.small_item) {
                tags.push('Small');
              }
              if (pack.access) {
                tags.push('Restricted');
              }
              return (
                <Table.Row key={pack.name} className="candystripe">
                  <Table.Cell>{pack.name}</Table.Cell>
                  <Table.Cell collapsing color="label" textAlign="right">
                    {tags.join(', ')}
                  </Table.Cell>
                  <Table.Cell collapsing textAlign="right">
                    <Button
                      fluid
                      tooltip={pack.desc}
                      tooltipPosition="left"
                      disabled={(amount_by_name[pack.name] || 0) >= max_order}
                      onClick={() =>
                        act('add', {
                          id: pack.id,
                        })
                      }
                    >
                      {formatMoney(
                        (self_paid && !pack.goody) || app_cost
                          ? Math.round(pack.cost * 1.1)
                          : pack.cost,
                      )}
                      {' cr'}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
}

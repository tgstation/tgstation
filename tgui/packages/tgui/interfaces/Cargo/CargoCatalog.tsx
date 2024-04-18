import { useMemo } from 'react';

import { useBackend, useSharedState } from '../../backend';
import {
  Button,
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
import { CargoData, SupplyCategory } from './types';

export function CargoCatalog(props) {
  const { express } = props;
  const { act, data } = useBackend<CargoData>();
  const { self_paid } = data;

  const supplies = Object.values(data.supplies);

  const [activeSupplyName, setActiveSupplyName] = useSharedState(
    'supply',
    supplies[0]?.name,
  );

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const activeSupply = useMemo(() => {
    return activeSupplyName === 'search_results'
      ? ({ packs: searchForSupplies(supplies, searchText) } as SupplyCategory)
      : supplies.find((supply) => supply.name === activeSupplyName);
  }, [activeSupplyName, supplies, searchText]);

  return (
    <Section
      fill
      title="Catalog"
      buttons={
        !express && (
          <>
            <CargoCartButtons />
            <Button
              color={self_paid ? 'average' : 'transparent'}
              icon={self_paid ? 'check-square-o' : 'square-o'}
              ml={2}
              onClick={() => act('toggleprivate')}
            >
              Buy Privately
            </Button>
          </>
        )
      }
    >
      <Stack fill>
        <Stack.Item grow>
          <CatalogTabs
            activeSupplyName={activeSupplyName}
            searchText={searchText}
            setActiveSupplyName={setActiveSupplyName}
            setSearchText={setSearchText}
            supplies={supplies}
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow={3}>
          <CatalogList activeSupply={activeSupply} />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type CatalogTabsProps = {
  activeSupplyName: string;
  searchText: string;
  setActiveSupplyName: (name: string) => void;
  setSearchText: (text: string) => void;
  supplies: SupplyCategory[];
};

function CatalogTabs(props: CatalogTabsProps) {
  const {
    activeSupplyName,
    searchText,
    setActiveSupplyName,
    setSearchText,
    supplies,
  } = props;

  return (
    <Tabs vertical>
      <Tabs.Tab
        key="search_results"
        selected={activeSupplyName === 'search_results'}
      >
        <Stack align="center">
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
          className="candystripe"
          color={supply.name === activeSupplyName ? 'green' : undefined}
          key={supply.name}
          selected={supply.name === activeSupplyName}
          onClick={() => {
            setActiveSupplyName(supply.name);
            setSearchText('');
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <span>{supply.name}</span>
            <span> {supply.packs.length}</span>
          </div>
        </Tabs.Tab>
      ))}
    </Tabs>
  );
}

type CatalogListProps = {
  activeSupply: SupplyCategory | undefined;
};

function CatalogList(props: CatalogListProps) {
  const { act, data } = useBackend<CargoData>();
  const { amount_by_name, max_order, self_paid, app_cost } = data;
  const { activeSupply } = props;

  return (
    <Section fill scrollable>
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
              <Table.Cell color="label">{pack.name}</Table.Cell>
              <Table.Cell collapsing color="average" textAlign="right">
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
                  mb={0.5}
                >
                  {formatMoney(
                    (self_paid && !pack.goody) || app_cost
                      ? Math.round(pack.cost * 1.1)
                      : pack.cost,
                  )}{' '}
                  cr
                </Button>
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
}

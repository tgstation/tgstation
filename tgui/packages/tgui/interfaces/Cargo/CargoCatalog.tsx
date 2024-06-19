import { sortBy } from 'common/collections';
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
  Tooltip,
} from '../../components';
import { formatMoney } from '../../format';
import { CargoCartButtons } from './CargoButtons';
import { searchForSupplies } from './helpers';
import { CargoData, Supply, SupplyCategory } from './types';

type Props = {
  express?: boolean;
};

export function CargoCatalog(props: Props) {
  const { express } = props;
  const { act, data } = useBackend<CargoData>();
  const { self_paid } = data;

  const supplies = Object.values(data.supplies);

  const [activeSupplyName, setActiveSupplyName] = useSharedState(
    'supply',
    supplies[0]?.name,
  );

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const packs = useMemo(() => {
    let fetched: Supply[] | undefined;

    if (activeSupplyName === 'search_results') {
      fetched = searchForSupplies(supplies, searchText);
    } else {
      fetched = supplies.find(
        (supply) => supply.name === activeSupplyName,
      )?.packs;
    }

    if (!fetched) return [];

    fetched = sortBy(fetched, (pack: Supply) => pack.name);

    return fetched;
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
              color={self_paid ? 'caution' : 'transparent'}
              icon={self_paid ? 'check-square-o' : 'square-o'}
              ml={2}
              onClick={() => act('toggleprivate')}
              tooltip="Use your own funds to purchase items."
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
            categories={supplies}
            searchText={searchText}
            setActiveSupplyName={setActiveSupplyName}
            setSearchText={setSearchText}
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow={express ? 2 : 3}>
          <CatalogList packs={packs} />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type CatalogTabsProps = {
  activeSupplyName: string;
  categories: SupplyCategory[];
  searchText: string;
  setActiveSupplyName: (name: string) => void;
  setSearchText: (text: string) => void;
};

function CatalogTabs(props: CatalogTabsProps) {
  const {
    activeSupplyName,
    categories,
    searchText,
    setActiveSupplyName,
    setSearchText,
  } = props;

  const sorted = sortBy(categories, (supply) => supply.name);

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
                  setActiveSupplyName(sorted[0]?.name);
                }
                setSearchText(value);
              }}
            />
          </Stack.Item>
        </Stack>
      </Tabs.Tab>

      {sorted.map((supply) => (
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
  packs: SupplyCategory['packs'];
};

function CatalogList(props: CatalogListProps) {
  const { act, data } = useBackend<CargoData>();
  const { amount_by_name = {}, max_order, self_paid, app_cost } = data;
  const { packs = [] } = props;

  return (
    <Section fill scrollable>
      <Table>
        {packs.map((pack) => {
          let color = '';
          const digits = Math.floor(Math.log10(pack.cost) + 1);
          if (self_paid) {
            color = 'caution';
          } else if (digits >= 5 && digits <= 6) {
            color = 'yellow';
          } else if (digits > 6) {
            color = 'bad';
          }

          return (
            <Table.Row key={pack.name} className="candystripe">
              <Table.Cell color="label">{pack.name}</Table.Cell>
              <Table.Cell collapsing>
                {!!pack.small_item && (
                  <Tooltip content="Small Item">
                    <Icon color="purple" name="compress-alt" />
                  </Tooltip>
                )}
              </Table.Cell>
              <Table.Cell collapsing>
                {!!pack.access && (
                  <Tooltip content="Restricted">
                    <Icon color="average" name="lock" />
                  </Tooltip>
                )}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  color={color}
                  tooltip={pack.desc}
                  tooltipPosition="left"
                  disabled={(amount_by_name[pack.name] || 0) >= max_order}
                  onClick={() =>
                    act('add', {
                      id: pack.id,
                    })
                  }
                  minWidth={5}
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

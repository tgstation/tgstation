import { sortBy } from 'common/collections';
import { Dispatch, useMemo, useState } from 'react';
import {
  Button,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
  Tooltip,
  ImageButton,
  Modal,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend, useSharedState } from '../../backend';
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
  const [showContents, setShowContents] = useState('');
  const [searchText, setSearchText] = useSharedState('search_text', '');
  const [activeSupplyName, setActiveSupplyName] = useSharedState(
    'supply',
    supplies[0]?.name,
  );

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
    <>
      {showContents && (
        <CatalogPackInfo
          packs={packs}
          name={showContents}
          closeContents={setShowContents}
        />
      )}
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
            <CatalogList packs={packs} openContents={setShowContents} />
          </Stack.Item>
        </Stack>
      </Section>
    </>
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
    <Stack fill vertical>
      <Stack.Item>
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
      </Stack.Item>
      <Stack.Item grow overflowY="auto" overflowX="hidden">
        <Tabs vertical>
          <Tabs.Tab
            key="search_results"
            selected={activeSupplyName === 'search_results'}
            style={{ display: 'none' }}
          />

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
      </Stack.Item>
    </Stack>
  );
}

type CatalogListProps = {
  packs: SupplyCategory['packs'];
  openContents: Dispatch<string>;
};

function CatalogList(props: CatalogListProps) {
  const { act, data } = useBackend<CargoData>();
  const { amount_by_name = {}, max_order, self_paid, app_cost } = data;
  const { packs = [], openContents } = props;

  return (
    <Section fill scrollable>
      {packs.map((pack) => {
        let color = '';
        const digits = Math.floor(Math.log10(pack.cost) + 1);
        if (self_paid) {
          color = 'orange';
        } else if (digits >= 5 && digits <= 6) {
          color = 'yellow';
        } else if (digits > 6) {
          color = 'bad';
        }

        return (
          <ImageButton
            key={pack.name}
            fluid
            dmIcon={pack.crate_icon}
            dmIconState={pack.crate_icon_state}
            imageSize={32}
            color={color}
            disabled={(amount_by_name[pack.name] || 0) >= max_order}
            buttonsAlt={
              <Button
                color="transparent"
                icon="info"
                onClick={() => openContents(pack.name)}
              />
            }
            onClick={() =>
              act('add', {
                id: pack.id,
              })
            }
          >
            <Stack fill textAlign="right">
              <Stack.Item grow textAlign="left">
                {pack.name}
              </Stack.Item>
              {(!!pack.small_item || !!pack.access || !!pack.contraband) && (
                <Stack.Item>
                  {!!pack.small_item && (
                    <Tooltip content="Small Item">
                      <Icon color="purple" name="compress-alt" />
                    </Tooltip>
                  )}
                  {!!pack.access && (
                    <Tooltip content="Restricted">
                      <Icon color="average" name="lock" />
                    </Tooltip>
                  )}
                  {!!pack.contraband && (
                    <Tooltip content="Contraband">
                      <Icon color="bad" name="pastafarianism" />
                    </Tooltip>
                  )}
                </Stack.Item>
              )}
              <Stack.Item width={5.5} color={'gold'} fontSize={0.8}>
                {formatMoney(
                  (self_paid && !pack.goody) || app_cost
                    ? Math.round(pack.cost * 1.1)
                    : pack.cost,
                )}{' '}
                cr
              </Stack.Item>
            </Stack>
          </ImageButton>
        );
      })}
    </Section>
  );
}

type CatalogContentsProps = {
  name: string;
  closeContents: Dispatch<string>;
  packs: SupplyCategory['packs'];
};

function CatalogPackInfo(props: CatalogContentsProps) {
  const { name, packs, closeContents } = props;
  const [activeTab, setActiveTab] = useState('contents');

  const pack = packs.find((pack) => pack.name === name);

  return (
    <Modal p={0} width={'50vw'} height={'50vh'}>
      <Section
        fill
        title={`${name}`}
        buttons={
          <Button
            icon={'close'}
            color={'bad'}
            onClick={() => closeContents('')}
          />
        }
      >
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === 'contents'}
                onClick={() => setActiveTab('contents')}
              >
                Contents
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'description'}
                onClick={() => setActiveTab('description')}
              >
                Description
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow mt={0} overflowY="auto">
            {activeTab === 'contents' &&
              pack?.contains?.map((item) => (
                <ImageButton
                  key={item.name}
                  fluid
                  dmIcon={item.icon}
                  dmIconState={item.icon_state}
                  imageSize={32}
                >
                  <Stack fill>
                    <Stack.Item textAlign="left">{item.name}</Stack.Item>
                    {!!item.amount && <Stack.Item>x{item.amount}</Stack.Item>}
                  </Stack>
                </ImageButton>
              ))}
            {activeTab === 'description' &&
              (pack?.desc || 'No description available.')}
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
}

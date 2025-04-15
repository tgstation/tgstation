import { sortBy } from 'common/collections';
import { Dispatch, SetStateAction, useMemo, useState } from 'react';
import {
  BlockQuote,
  Button,
  Icon,
  ImageButton,
  Modal,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend, useSharedState } from '../../backend';
import { SearchBar } from '../common/SearchBar';
import { searchForSupplies } from './helpers';
import { CargoData, Supply, SupplyCategory } from './types';

type Props = {
  express?: boolean;
};

export function CargoCatalog(props: Props) {
  const { data } = useBackend<CargoData>();
  const { express } = props;

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
      <Stack fill g={0}>
        <Stack.Item grow mr={-0.33}>
          <Section fill>
            <CatalogTabs
              express={express}
              activeSupplyName={activeSupplyName}
              categories={supplies}
              searchText={searchText}
              setActiveSupplyName={setActiveSupplyName}
              setSearchText={setSearchText}
            />
          </Section>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow={express ? 2 : 3}>
          <Section fill scrollable>
            <CatalogList packs={packs} openContents={setShowContents} />
          </Section>
        </Stack.Item>
      </Stack>
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

function CatalogTabs(props: CatalogTabsProps & Props) {
  const { act, data } = useBackend<CargoData>();
  const {
    activeSupplyName,
    categories,
    searchText,
    setActiveSupplyName,
    setSearchText,
    express,
  } = props;
  const { self_paid } = data;

  const sorted = sortBy(categories, (supply) => supply.name);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <SearchBar
          query={searchText}
          onSearch={(value) => {
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
      <Stack.Item grow p={1} m={-1} mt={1} overflowY="auto">
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
              <Stack justify="space-between">
                <span>{supply.name}</span>
                <span> {supply.packs.length}</span>
              </Stack>
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        {!express && (
          <Button
            fluid
            color={self_paid ? 'caution' : 'transparent'}
            icon={self_paid ? 'check-square-o' : 'square-o'}
            onClick={() => act('toggleprivate')}
            tooltip="Use your own funds to purchase items."
            tooltipPosition="top"
          >
            Buy Privately
          </Button>
        )}
      </Stack.Item>
    </Stack>
  );
}

type CatalogListProps = {
  packs: SupplyCategory['packs'];
  openContents: Dispatch<SetStateAction<string>>;
};

function CatalogList(props: CatalogListProps) {
  const { act, data } = useBackend<CargoData>();
  const { amount_by_name = {}, max_order, self_paid, app_cost } = data;
  const { packs = [], openContents } = props;

  return (
    <>
      {packs.map((pack) => {
        let color = '';
        const digits = Math.floor(Math.log10(pack.cost) + 1);
        if (self_paid) {
          color = 'yellow';
        } else if (digits >= 5 && digits <= 6) {
          color = 'orange';
        } else if (digits > 6) {
          color = 'bad';
        }

        const privateBuy = (self_paid && !pack.goody) || app_cost;
        const tooltipIcon = (content: string, icon: string, color: string) => (
          <Stack.Item>
            <Tooltip content={content}>
              <Icon color={color} name={icon} />
            </Tooltip>
          </Stack.Item>
        );

        return (
          <ImageButton
            key={pack.id}
            fluid
            dmIcon={pack.first_item_icon}
            dmIconState={pack.first_item_icon_state}
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
                  <Stack reverse>
                    {!!pack.small_item &&
                      tooltipIcon('Small Item', 'compress-alt', 'purple')}
                    {!!pack.access &&
                      tooltipIcon('Restricted', 'lock', 'average')}
                    {!!pack.contraband &&
                      tooltipIcon('Contraband', 'pastafarianism', 'bad')}
                  </Stack>
                </Stack.Item>
              )}
              <Stack.Item align="center" width={5.5} mt={-0.75} mb={-0.75}>
                <Stack vertical color="gold" lineHeight={0.75} fontSize={0.85}>
                  <Stack.Item
                    opacity={privateBuy && 0.75}
                    style={{ textDecoration: privateBuy && 'red line-through' }}
                  >
                    {formatMoney(pack.cost)} cr
                  </Stack.Item>
                  {!!privateBuy && (
                    <Stack.Item>
                      {formatMoney(Math.round(pack.cost * 1.1))} cr
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
            </Stack>
          </ImageButton>
        );
      })}
    </>
  );
}

type CatalogContentsProps = {
  name: string;
  closeContents: Dispatch<SetStateAction<string>>;
  packs: SupplyCategory['packs'];
};

function CatalogPackInfo(props: CatalogContentsProps) {
  const { name, packs, closeContents } = props;
  const pack = packs.find((pack) => pack.name === name);
  const contains = pack?.contains;

  return (
    <Modal p={1} width="50vw" height="50vh">
      <Stack fill vertical>
        <Stack.Item>
          <Section
            fill
            title={name}
            buttons={
              <Button
                icon="close"
                color="bad"
                onClick={() => closeContents('')}
              />
            }
          >
            <BlockQuote>{pack?.desc || 'No description available.'}</BlockQuote>
          </Section>
        </Stack.Item>
        <Stack.Item m={0} grow>
          <Section fill scrollable>
            {contains && contains.length > 0 ? (
              contains.map((item) => (
                <ImageButton
                  key={item.name}
                  fluid
                  dmIcon={item.icon}
                  dmIconState={item.icon_state}
                  buttonsAlt={
                    !!item.amount && (
                      <Stack.Item backgroundColor="rgba(255, 255, 255, 0.1">
                        x{item.amount}
                      </Stack.Item>
                    )
                  }
                  imageSize={32}
                >
                  <Stack fill>
                    <Stack.Item textAlign="left">{item.name}</Stack.Item>
                  </Stack>
                </ImageButton>
              ))
            ) : (
              <Stack fill vertical align="center" justify="center">
                <Stack.Item>
                  <Icon name="triangle-exclamation" size={6} color="orange" />
                </Stack.Item>
                <Stack.Item mt={2} color="label" textAlign="center">
                  {`We can't find information about even the approximate contents
                  of this order.`}
                </Stack.Item>
              </Stack>
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}

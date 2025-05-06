import { Component, Fragment } from 'react';
import {
  Box,
  Button,
  Dimmer,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';
import { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  calculateDangerLevel,
  calculateProgression,
  dangerLevelsTooltip,
} from './calculateDangerLevel';
import { GenericUplink, Item } from './GenericUplink';
import { PrimaryObjectiveMenu } from './PrimaryObjectiveMenu';

type UplinkItem = {
  id: string;
  name: string;
  icon: string;
  icon_state: string;
  cost: number;
  desc: string;
  category: string;
  purchasable_from: number;
  restricted: BooleanLike;
  limited_stock: number;
  stock_key: string;
  restricted_roles: string;
  restricted_species: string;
  progression_minimum: number;
  population_minimum: number;
  cost_override_string: string;
  lock_other_purchases: BooleanLike;
  ref?: string;
};

type UplinkData = {
  telecrystals: number;
  progression_points: number;
  joined_population?: number;
  lockable: BooleanLike;
  current_progression_scaling: number;
  uplink_flag: number;
  assigned_role: string;
  assigned_species: string;
  debug: BooleanLike;
  extra_purchasable: UplinkItem[];
  extra_purchasable_stock: {
    [key: string]: number;
  };
  current_stock: {
    [key: string]: number;
  };

  has_progression: BooleanLike;
  primary_objectives: {
    [key: number]: string;
  };
  purchased_items: number;
  shop_locked: BooleanLike;
  can_renegotiate: BooleanLike;
};

type UplinkState = {
  allItems: UplinkItem[];
  allCategories: string[];
  currentTab: number;
};

type ServerData = {
  items: UplinkItem[];
  categories: string[];
};

type ItemExtraData = Item & {
  extraData: {
    ref?: string;
    icon: string;
    icon_state: string;
  };
};

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;

export class Uplink extends Component<{}, UplinkState> {
  constructor(props) {
    super(props);
    this.state = {
      allItems: [],
      allCategories: [],
      currentTab: 0,
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset('uplink.json')).then(
        (response) => response.json(),
      );
    }
    const { data } = useBackend<UplinkData>();

    const uplinkFlag = data.uplink_flag;
    const uplinkRole = data.assigned_role;
    const uplinkSpecies = data.assigned_species;

    const uplinkData = await fetchServerData;
    uplinkData.items = uplinkData.items.sort((a, b) => {
      if (a.progression_minimum < b.progression_minimum) {
        return -1;
      }
      if (a.progression_minimum > b.progression_minimum) {
        return 1;
      }
      return 0;
    });

    const availableCategories: string[] = [];
    uplinkData.items = uplinkData.items.filter((value) => {
      if (
        value.restricted_roles.length > 0 &&
        !value.restricted_roles.includes(uplinkRole) &&
        !data.debug
      ) {
        return false;
      }
      if (
        value.restricted_species.length > 0 &&
        !value.restricted_species.includes(uplinkSpecies) &&
        !data.debug
      ) {
        return false;
      }
      {
        if (value.purchasable_from & uplinkFlag) {
          return true;
        }
      }
      return false;
    });

    uplinkData.items.forEach((item) => {
      if (!availableCategories.includes(item.category)) {
        availableCategories.push(item.category);
      }
    });

    uplinkData.categories = uplinkData.categories.filter((value) =>
      availableCategories.includes(value),
    );

    this.setState({
      allItems: uplinkData.items,
      allCategories: uplinkData.categories,
    });
  }

  render() {
    const { data, act } = useBackend<UplinkData>();
    const {
      telecrystals,
      progression_points,
      joined_population,
      primary_objectives,
      can_renegotiate,
      has_progression,
      current_progression_scaling,
      extra_purchasable,
      extra_purchasable_stock,
      current_stock,
      lockable,
      purchased_items,
      shop_locked,
    } = data;
    const { allItems, allCategories, currentTab } = this.state as UplinkState;
    const itemsToAdd = [...allItems];
    const items: ItemExtraData[] = [];
    itemsToAdd.push(...extra_purchasable);
    for (let i = 0; i < extra_purchasable.length; i++) {
      const item = extra_purchasable[i];
      if (!allCategories.includes(item.category)) {
        allCategories.push(item.category);
      }
    }
    for (let i = 0; i < itemsToAdd.length; i++) {
      const item = itemsToAdd[i];
      const hasEnoughProgression =
        progression_points >= item.progression_minimum;
      const hasEnoughPop =
        !joined_population || joined_population >= item.population_minimum;

      let stock: number | null = current_stock[item.stock_key];
      if (item.ref) {
        stock = extra_purchasable_stock[item.ref];
      }
      if (!stock && stock !== 0) {
        stock = null;
      }
      const canBuy = telecrystals >= item.cost && (stock === null || stock > 0);
      items.push({
        id: item.id,
        name: item.name,
        icon: item.icon,
        icon_state: item.icon_state,
        category: item.category,
        desc: (
          <>
            <Box>{item.desc}</Box>
            {(item.lock_other_purchases && (
              <NoticeBox mt={1}>
                Taking this item will lock you from further purchasing from the
                marketplace. Additionally, if you have already purchased an
                item, you will not be able to purchase this.
              </NoticeBox>
            )) ||
              null}
          </>
        ),
        cost: (
          <Box>
            {item.cost_override_string || `${item.cost} TC`}
            {has_progression ? (
              <>
                ,&nbsp;
                <Box as="span">
                  {calculateDangerLevel(item.progression_minimum, true)}
                </Box>
              </>
            ) : (
              ''
            )}
          </Box>
        ),
        population_tooltip:
          'This item is not cleared for operations performed against stations crewed by fewer than ' +
          item.population_minimum +
          ' people.',
        insufficient_population: !hasEnoughPop,
        disabled:
          !canBuy ||
          !hasEnoughPop ||
          (has_progression && !hasEnoughProgression) ||
          (item.lock_other_purchases && purchased_items > 0),
        extraData: {
          ref: item.ref,
          icon: item.icon,
          icon_state: item.icon_state,
        },
      });
    }

    return (
      <Window width={700} height={600} theme="syndicate">
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item>
              <Section fitted>
                <Stack fill>
                  {!!has_progression && (
                    <Stack.Item p="4px">
                      <Tooltip
                        content={
                          <Box>
                            <Box>
                              <Box>Your current level of threat.</Box> Threat
                              determines what items you can purchase.&nbsp;
                              <Box mt={0.5}>
                                {/* A minute in deciseconds */}
                                Threat passively increases by{' '}
                                <Box color="green" as="span">
                                  {calculateProgression(
                                    current_progression_scaling,
                                  )}
                                </Box>
                                &nbsp;every minute
                              </Box>
                              {dangerLevelsTooltip}
                            </Box>
                          </Box>
                        }
                      >
                        {calculateDangerLevel(progression_points, false)}
                      </Tooltip>
                    </Stack.Item>
                  )}
                  {!!primary_objectives && (
                    <Stack.Item grow={1}>
                      <Tabs fluid>
                        {primary_objectives && (
                          <Tabs.Tab
                            style={{
                              overflow: 'hidden',
                              whiteSpace: 'nowrap',
                              textOverflow: 'ellipsis',
                            }}
                            icon="star"
                            selected={currentTab === 0}
                            onClick={() => this.setState({ currentTab: 0 })}
                          >
                            Primary Objectives
                          </Tabs.Tab>
                        )}
                        <Tabs.Tab
                          style={{
                            overflow: 'hidden',
                            whiteSpace: 'nowrap',
                            textOverflow: 'ellipsis',
                          }}
                          icon="store"
                          selected={currentTab === 2}
                          onClick={() => this.setState({ currentTab: 2 })}
                        >
                          Market
                        </Tabs.Tab>
                      </Tabs>
                    </Stack.Item>
                  )}

                  {!!lockable && (
                    <Stack.Item>
                      <Button
                        lineHeight={2.5}
                        textAlign="center"
                        icon="lock"
                        color="transparent"
                        px={2}
                        onClick={() => act('lock')}
                      >
                        Lock
                      </Button>
                    </Stack.Item>
                  )}
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              {(currentTab === 0 && primary_objectives && (
                <PrimaryObjectiveMenu
                  primary_objectives={primary_objectives}
                  can_renegotiate={can_renegotiate}
                />
              )) || (
                <>
                  <GenericUplink
                    currency={`${telecrystals} TC`}
                    categories={allCategories}
                    items={items}
                    handleBuy={(item: ItemExtraData) => {
                      if (!item.extraData?.ref) {
                        act('buy', { path: item.id });
                      } else {
                        act('buy', { ref: item.extraData.ref });
                      }
                    }}
                  />
                  {(shop_locked && !data.debug && (
                    <Dimmer>
                      <Box
                        color="red"
                        fontFamily={'Bahnschrift'}
                        fontSize={3}
                        align={'top'}
                        as="span"
                      >
                        SHOP LOCKED
                      </Box>
                    </Dimmer>
                  )) ||
                    null}
                </>
              )}
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
}

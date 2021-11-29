import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { GenericUplink, Item } from './GenericUplink';
import { Component } from 'inferno';
import { fetchRetry } from '../../http';
import { resolveAsset } from '../../assets';
import { BooleanLike } from 'common/react';
import { Box } from '../../components';
import { logger } from '../../logging';

export const MAX_SEARCH_RESULTS = 25;

const calculateProgression = (progression_points: number) => {
  return Math.round(progression_points / 6) / 100;
};

type UplinkItem = {
  id: string,
  name: string,
  cost: number,
  desc: string,
  category: string,
  purchasable_from: number,
  restricted: BooleanLike,
  limited_stock: number,
  restricted_roles: string,
  progression_minimum: number,
}

type ObjectiveUiButton = {
  name: string,
  tooltip: string,
  icon: string,
  action: string,
}

type Objective = {
  name: string,
  description: string,
  progression_minimum: number,
  progression_reward: number,
  telecrystal_reward: number,
  ui_buttons?: ObjectiveUiButton[],
}

type UplinkData = {
  telecrystals: number,
  progression_points: number,
  uplink_flag: number,
  has_objectives: BooleanLike,
  potential_objectives: Objective[],
  active_objectives: Objective[],
}

type UplinkState = {
  allItems: UplinkItem[],
  allCategories: string[]
}

type ServerData = {
  items: UplinkItem[],
  categories: string[],
}

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;

export class Uplink extends Component<{}, UplinkState> {
  constructor() {
    super();
    this.state = {
      allItems: [],
      allCategories: [],
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset("uplink.json"))
        .then(response => response.json());
    }
    const { data } = useBackend<UplinkData>(this.context);

    const uplinkFlag = data.uplink_flag;

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
    uplinkData.items = uplinkData.items.filter(value => {
      if (value.purchasable_from & uplinkFlag) {
        if (!availableCategories.includes(value.category)) {
          availableCategories.push(value.category);
        }
        return true;
      }
      return false;
    });

    uplinkData.categories = uplinkData.categories.filter(value =>
      availableCategories.includes(value));
    logger.log(availableCategories);

    this.setState({
      allItems: uplinkData.items,
      allCategories: uplinkData.categories,
    });
  }

  render() {
    const { data, act } = useBackend<UplinkData>(this.context);
    const {
      telecrystals,
      progression_points,
    } = data;
    const {
      allItems,
      allCategories,
    } = this.state as UplinkState;
    const items: Item[] = [];
    for (let i = 0; i < allItems.length; i++) {
      const item = allItems[i];
      const canBuy = telecrystals >= item.cost;
      const hasEnoughProgression
        = progression_points >= item.progression_minimum;
      items.push({
        id: item.id,
        name: item.name,
        category: item.category,
        desc: (
          <Box>
            {item.desc}
          </Box>
        ),
        cost: (
          <Box>
            {item.cost} TC,&nbsp;
            {calculateProgression(item.progression_minimum)} Reputation
          </Box>
        ),
        disabled: !canBuy || !hasEnoughProgression,
      });
    }
    return (
      <Window
        width={620}
        height={580}
        theme="syndicate">
        <Window.Content scrollable>
          <GenericUplink
            currency={(
              <Box color="good">
                {telecrystals} TC,&nbsp;
                {calculateProgression(progression_points)} Reputation
              </Box>
            )}
            categories={allCategories}
            items={items}
            handleBuy={(item) => {
              act("buy", { path: item.id });
            }}
            handleLock={(event) => {
              act("lock");
            }}
          />
        </Window.Content>
      </Window>
    );
  }

}



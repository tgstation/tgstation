import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button, Image, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  all_worlds: string[];
  attack_types: AttackTypeData[];
  max_hp: number;
  max_mp: number;
  ui_panel: string;
  feedback_message: string;
  player_current_world: string;
  unlocked_world_modifier: number;
  latest_unlocked_world_position: number;
  player_gold: number;
  player_current_hp: number;
  player_current_mp: number;
  enemy_icon_id: string;
  enemy_name: string;
  enemy_max_hp: number;
  enemy_hp: number;
  enemy_mp: number;
  cost_of_items: number;
  equipped_gear: EquippedGear[];
  shop_items: string[];
};

type AttackTypeData = {
  name: string;
  tooltip: string;
};

type EquippedGear = {
  name: string;
  slot: string;
};

export const BattleArcade = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    ui_panel,
    player_current_hp,
    player_current_mp,
    max_hp,
    max_mp,
    player_gold,
    equipped_gear = [],
  } = data;
  return (
    <Window width={420} height={415}>
      <Window.Content>
        <Section align="center">
          Player stats <br /> HP:{' '}
          <span style={{ color: '#c91212' }}>
            {player_current_hp}/{max_hp}
          </span>{' '}
          | MP:{' '}
          <span style={{ color: '#0783b5' }}>
            {player_current_mp}/{max_mp}
          </span>{' '}
          | <span style={{ color: '#b8c10b' }}>{player_gold || 0}</span>G <br />
          {!equipped_gear.length && 'No gear equipped!'}
          {equipped_gear.map((gear, index) => (
            <>
              {gear.slot}: {gear.name} <br />
            </>
          ))}
        </Section>
        {ui_panel === 'Shop' ? (
          <ShopPanel />
        ) : ui_panel === 'World Map' ? (
          <WorldMapPanel />
        ) : ui_panel === 'Battle' ? (
          <BattlePanel />
        ) : ui_panel === 'Between Battle' ? (
          <BetweenBattlePanel />
        ) : (
          <GameOverPanel />
        )}
      </Window.Content>
    </Window>
  );
};

const ShopPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { shop_items, cost_of_items, unlocked_world_modifier } = data;
  return (
    <Section align="center">
      <Box>Welcome to the Inn!</Box>
      <Image width={8} src={resolveAsset('shopkeeper.png')} />
      <Box m={2}>
        Feel free to browse our wares, or take a nap. I&apos;ll be here to
        ensure you&apos;ll get a good night&apos;s rest without worry of
        ambushing or robbery.
      </Box>
      {shop_items.map((item, index) => (
        <Button
          key={index}
          icon="shield"
          width="100%"
          onClick={() => act('buy_item', { purchasing_item: item })}
        >
          {item}: {cost_of_items * unlocked_world_modifier}G
        </Button>
      ))}
      <Button icon="bed" width="100%" onClick={() => act('sleep')}>
        Rest {cost_of_items / 2}G
      </Button>
      <Button icon="arrow-left" width="100%" onClick={() => act('leave')}>
        Leave Inn
      </Button>
    </Section>
  );
};

const WorldMapPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { all_worlds, latest_unlocked_world_position } = data;
  return (
    <Section align="center">
      <Box>
        <Button color="transparent" icon="map" /> WORLD MAP{' '}
        <Button color="transparent" icon="map" />
      </Box>
      <Box m={1}>
        The further down you go, the harder the enemies will be, but the more
        loot you will get.
      </Box>
      <Button icon="house" width="100%" onClick={() => act('enter_inn')}>
        Enter Inn
      </Button>
      {all_worlds.map((world, index) => (
        <Button
          key={index}
          disabled={index >= latest_unlocked_world_position}
          icon="fist-raised"
          width="100%"
          onClick={() => act('start_fight', { selected_arena: world })}
        >
          {world}
        </Button>
      ))}
    </Section>
  );
};

const BattlePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    attack_types,
    enemy_icon_id,
    enemy_name,
    enemy_max_hp,
    enemy_hp,
    enemy_mp,
    feedback_message,
  } = data;
  return (
    <Section align="center">
      {feedback_message && <Box>{feedback_message}</Box>}
      <Box>
        {enemy_name}&apos;s HP: {enemy_hp}/{enemy_max_hp}
      </Box>
      <Box>
        {enemy_name}&apos;s MP: {enemy_mp}
      </Box>
      <Image width={10} src={resolveAsset(enemy_icon_id)} />
      {attack_types.map((attack, index) => (
        <Button
          key={index}
          icon="fist-raised"
          width="100%"
          tooltip={attack.tooltip}
          onClick={() => act(attack.name)}
        >
          {attack.name}
        </Button>
      ))}
      <Button.Confirm
        icon="shoe-prints"
        width="100%"
        confirmContent="Really Flee?"
        onClick={() => act('flee')}
      >
        Flee (Lose half your Gold)
      </Button.Confirm>
    </Section>
  );
};

const BetweenBattlePanel = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Section align="center">
      <Image width={10} src={resolveAsset('fireplace.png')} />
      <Box m={1}>
        As night sets, you can choose to rest. This will restore your health and
        mana to full before the next battle, but you may also be ambushed,
        forcing you into the next fight without any additional healing.
      </Box>
      <Button icon="bed" width="100%" onClick={() => act('continue_with_rest')}>
        Attempt to sleep
      </Button>
      <Button
        icon="fire"
        width="100%"
        onClick={() => act('continue_without_rest')}
      >
        Leave without sleeping
      </Button>
      <Button
        icon="shoe-prints"
        width="100%"
        onClick={() => act('abandon_quest')}
      >
        Abandon Quest
      </Button>
    </Section>
  );
};

const GameOverPanel = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Section align="center">
      <Box color="red" fontSize="32px" m={1}>
        Game Over
      </Box>
      <Box fontSize="15px">
        <Button
          lineHeight={2}
          fluid
          icon="arrow-left"
          onClick={() => act('restart')}
        >
          Main Menu
        </Button>
      </Box>
    </Section>
  );
};

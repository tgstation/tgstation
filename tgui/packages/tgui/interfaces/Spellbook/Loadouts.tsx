import { Box, Button, Divider, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { PointLocked } from './Locked';
import type { SpellbookData } from './types';

export function Loadouts(props) {
  const { data } = useBackend<SpellbookData>();
  const { points } = data;
  // Future todo : Make these datums on the DM side
  return (
    <Stack ml={0.5} mt={-0.5} vertical fill>
      {points < 10 && <PointLocked />}
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            loadoutId="loadout_classic"
            loadoutColor="purple"
            name="Классический Волшебник"
            icon="fire"
            author="Архиканцлер Грей"
            blurb="
                Это классический волшебник, безумно популярный в
                2550-х годах. Включает Fireball, Magic Missile,
                Ei Nath и Ethereal Jaunt.
                Каждую часть этого набора легко использовать.
              "
          />
          <SingleLoadout
            name="Сила Мьёльнира"
            icon="hammer"
            loadoutId="loadout_hammer"
            loadoutColor="green"
            author="Егудиэль Миродрожатель"
            blurb="
                Сила могучего Мьёльнира! Лучше не терять его.
                Этот набор включает Summon Item, Mutate, Blink, Force Wall,
                Tesla Blast и Mjolnir. Mutate - ваша утилита в этом случае.
              "
          />
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            name="Фантастическая Армия"
            icon="pastafarianism"
            loadoutId="loadout_army"
            loadoutColor="yellow"
            author="Просперо Зачарованный Камень"
            blurb="
                Зачем убивать, когда другие с радостью сделают это за вас?
                Примите хаос: Soulshards, Staff of Change,
                Necro Stone, Teleport и Jaunt!
             "
          />
          <SingleLoadout
            name="Похититель Душ"
            icon="skull"
            loadoutId="loadout_tap"
            loadoutColor="white"
            author="Том Пустой"
            blurb="
                Примите тьму и воспользуйтесь своей душой.
                Используйте мощные заклинания, такие как Ei Nath, меняя тела с
                Mind Swap и начиная Soul Tap заново.
              "
          />
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

type Props = {
  author: string;
  blurb: string;
  icon: string;
  loadoutColor: string;
  loadoutId: string;
  name: string;
};

function SingleLoadout(props: Props) {
  const { act } = useBackend();
  const { author, name, blurb, icon, loadoutId, loadoutColor } = props;

  return (
    <Stack.Item grow>
      <Section width={19.17} title={name}>
        {blurb}
        <Divider />
        <Button.Confirm
          confirmContent="Подтвердить покупку?"
          confirmIcon="dollar-sign"
          confirmColor="good"
          fluid
          icon={icon}
          onClick={() =>
            act('purchase_loadout', {
              id: loadoutId,
            })
          }
        >
          Приобрести набор
        </Button.Confirm>
        <Divider />
        <Box color={loadoutColor}>Добавлено {author}.</Box>
      </Section>
    </Stack.Item>
  );
}

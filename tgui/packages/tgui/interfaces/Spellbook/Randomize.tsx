import { Button, Divider, NoticeBox, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { PointLocked } from './Locked';
import type { SpellbookData } from './types';

export function Randomize(props) {
  const { act, data } = useBackend<SpellbookData>();
  const { points, semi_random_bonus, full_random_bonus } = data;

  return (
    <Stack fill vertical>
      {points < 10 && <PointLocked />}
      <Stack.Item>
        Частичная рандомизация гарантирует получение хотя бы некоторой мобильности и смертоносности.
        Гарантировано получение заклинаний на {semi_random_bonus} очков.
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          confirmContent="Погнали?"
          confirmIcon="dice-three"
          lineHeight={6}
          fluid
          icon="dice-three"
          onClick={() => act('semirandomize')}
        >
          Частичная рандомизация
        </Button.Confirm>
        <Divider />
      </Stack.Item>
      <Stack.Item>
        Полная рандомизация даст что угодно. И назад дороги нет!
        Гарантировано получение заклинаний на {full_random_bonus} очков.
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger>
          <Button.Confirm
            confirmContent="Погнали?"
            confirmIcon="dice"
            lineHeight={6}
            fluid
            color="black"
            icon="dice"
            onClick={() => act('randomize')}
          >
            Полная рандомизация
          </Button.Confirm>
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
}

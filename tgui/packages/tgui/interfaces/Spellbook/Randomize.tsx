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
        Semi-Randomize will ensure you at least get some mobility and lethality.
        Guaranteed to have {semi_random_bonus} points worth of spells.
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          confirmContent="Cowabunga it is?"
          confirmIcon="dice-three"
          lineHeight={6}
          fluid
          icon="dice-three"
          onClick={() => act('semirandomize')}
        >
          Semi-Randomize
        </Button.Confirm>
        <Divider />
      </Stack.Item>
      <Stack.Item>
        Full Random will give you anything. There&apos;s no going back, either!
        Guaranteed to have {full_random_bonus} points worth of spells.
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger>
          <Button.Confirm
            confirmContent="Cowabunga it is?"
            confirmIcon="dice"
            lineHeight={6}
            fluid
            color="black"
            icon="dice"
            onClick={() => act('randomize')}
          >
            Full Random
          </Button.Confirm>
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
}

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
            name="The Classic Wizard"
            icon="fire"
            author="Archchancellor Gray"
            blurb="
                This is the classic wizard, crazy popular in
                the 2550's. Comes with Fireball, Magic Missile,
                Ei Nath, and Ethereal Jaunt. The key here is that
                every part of this kit is very easy to pick up and use.
              "
          />
          <SingleLoadout
            name="Mjolnir's Power"
            icon="hammer"
            loadoutId="loadout_hammer"
            loadoutColor="green"
            author="Jegudiel Worldshaker"
            blurb="
                The power of the mighty Mjolnir! Best not to lose it.
                This loadout has Summon Item, Mutate, Blink, Force Wall,
                Tesla Blast, and Mjolnir. Mutate is your utility in this case:
                Use it for limited ranged fire and getting out of bad blinks.
              "
          />
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            name="Fantastical Army"
            icon="pastafarianism"
            loadoutId="loadout_army"
            loadoutColor="yellow"
            author="Prospero Spellstone"
            blurb="
                Why kill when others will gladly do it for you?
                Embrace chaos with your kit: Soulshards, Staff of Change,
                Necro Stone, Teleport, and Jaunt! Remember, no offense spells!
             "
          />
          <SingleLoadout
            name="Soul Tapper"
            icon="skull"
            loadoutId="loadout_tap"
            loadoutColor="white"
            author="Tom the Empty"
            blurb="
                Embrace the dark, and tap into your soul.
                You can recharge very long recharge spells
                like Ei Nath by jumping into new bodies with
                Mind Swap and starting Soul Tap anew.
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
          confirmContent="Confirm Purchase?"
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
          Purchase Loadout
        </Button.Confirm>
        <Divider />
        <Box color={loadoutColor}>Added by {author}.</Box>
      </Section>
    </Stack.Item>
  );
}

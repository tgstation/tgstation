import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Button, Dropdown, Section, Stack } from '../components';
import { Window } from '../layouts';

const weaponlist = [
  "Fist Fight",
  "Melee Only",
  "Any Weapons",
];

const stakelist = [
  "No Stakes",
  "Holy Match",
  "Money Match",
  "Your Soul",
];

const weaponblurb = [
  "You will fight with your fists only. Any weapons will be considered a violation.",
  "You can fight with weapons, or fists if you have none. Ranged weapons are a violation.",
  "You can fight with any and all weapons as you please. Try not to kill them, okay?",
];

const stakesblurb = [
  "No stakes, just for fun. Who doesn't love some recreational sparring?",
  "A match for the chaplain's deity. The Chaplain suffers large consequences for failure, but advances their sect by winning.",
  "A match with money on the line. Whomever wins takes all the money of whomever loses.",
  "A lethal match with the loser's soul becoming under ownership of the winner.",
];

type Info = {
  set_weapon: number;
  set_area: string;
  set_stakes: number;
  left_sign: string;
  right_sign: string;
  in_area: BooleanLike;
  possible_areas: Array<string>;
};

export const SparringContract = (props, context) => {
  const { data, act } = useBackend<Info>(context);
  const {
    set_weapon,
    set_area,
    set_stakes,
    possible_areas,
    left_sign,
    right_sign,
  } = data;
  const [weapon, setWeapon] = useLocalState(context, "weapon", set_weapon);
  const [area, setArea] = useLocalState(context, "area", set_area);
  const [stakes, setStakes] = useLocalState(context, "stakes", set_stakes);
  return (
    <Window
      width={420}
      height={380}>
      <Window.Content>
        <Section fill>
          <Stack vertical fill>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item fontSize="16px">
                  Weapons:
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    width="100%"
                    selected={weaponlist[weapon-1]}
                    options={weaponlist}
                    onSelected={value =>
                      setWeapon(weaponlist.findIndex(title => (
                        title === value
                      ))+1)} />
                </Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    {weaponblurb[weapon-1]}
                  </BlockQuote>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item fontSize="16px">
                  Arena:
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    width="100%"
                    selected={area}
                    options={possible_areas}
                    onSelected={value => setArea(value)} />
                </Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    This fight will take place in the {area}.
                    Leaving the arena mid-fight is a violation.
                  </BlockQuote>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item fontSize="16px">
                  Stakes:
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    width="100%"
                    selected={stakelist[stakes-1]}
                    options={stakelist}
                    onSelected={value =>
                      setStakes(stakelist.findIndex(title => (
                        title === value
                      ))+1)} />
                </Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    {stakesblurb[stakes-1]}
                  </BlockQuote>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack grow textAlign="center">
                <Stack.Item
                  fontSize={left_sign !== "none" && "14px"}
                  grow>
                  {left_sign === 'none' && (
                    <Button
                      icon="pen"
                      onClick={() => act('sign', {
                        "weapon": weapon,
                        "arena": area,
                        "stakes": stakes,
                        "sign_position": "left",
                      })}>
                      Sign Here
                    </Button>
                  ) || (
                    left_sign
                  )}
                </Stack.Item>
                <Stack.Item fontSize="16px">
                  VS
                </Stack.Item>
                <Stack.Item
                  fontSize={right_sign !== "none" && "14px"}
                  grow>
                  {right_sign === "none" && (
                    <Button
                      icon="pen"
                      onClick={() => act('sign', {
                        "weapon": weapon,
                        "area": area,
                        "stakes": stakes,
                      })}>
                      Sign Here
                    </Button>
                  ) || (
                    right_sign
                  )}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item textAlign="center">
              <Button
                tooltip="Both participants need to be in the arena!"
                color="red"
                icon="exclamation-triangle" />
              <Button
                disabled icon="fist-raised">
                FIGHT!
              </Button>
              <Button
                tooltip="You need signatures from both fighters!"
                color="red"
                icon="exclamation-triangle" />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

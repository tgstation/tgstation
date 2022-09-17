import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

const teleportstyle = {
  color: 'yellow',
};

const robestyle = {
  color: 'lightblue',
};

const destructionstyle = {
  color: 'red',
};

const defensestyle = {
  color: 'orange',
};

const transportstyle = {
  color: 'yellow',
};

const summonstyle = {
  color: 'cyan',
};

const ritualstyle = {
  color: 'violet',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
};

type Info = {
  objectives: Objective[];
};

export const AntagInfoWizard = (props, context) => {
  return (
    <Window width={620} height={580} theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <Stack.Item textColor="red" fontSize="20px">
                  You are the Space Wizard!
                </Stack.Item>
                <Stack.Item>
                  <ObjectivePrintout />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fill title="Spellbook">
              <Stack vertical fill>
                <Stack.Item>
                  You have a spellbook which is bound to you. You can use it to
                  choose a magical arsenal.
                  <br />
                  <span style={destructionstyle}>
                    The deadly page has the offensive spells, to destroy your
                    enemies.
                  </span>
                  <br />
                  <span style={defensestyle}>
                    The defensive page has defensive spells, to keep yourself
                    alive. Remember, you may be powerful, but you are still only
                    human.
                  </span>
                  <br />
                  <span style={transportstyle}>
                    The transport page has mobility spells, very important
                    aspect of staying alive and getting things done.
                  </span>
                  <br />
                  <span style={summonstyle}>
                    The summoning page has summoning and other helpful spells
                    for not fighting alone. Careful, not every summon is on your
                    side.
                  </span>
                  <br />
                  <span style={ritualstyle}>
                    The rituals page has powerful global effects, that will pit
                    the station against itself. Do mind that these are either
                    expensive, or just for panache.
                  </span>
                </Stack.Item>
                <Stack.Item textColor="lightgreen">
                  (If you are unsure what to get or are new to the Federation,
                  go to the &quot;Wizard Approved Loadouts&quot; section. There
                  you will find some kits that work fairly well for new
                  wizards.)
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Misc Gear">
              <Stack>
                <Stack.Item>
                  <span style={teleportstyle}>Teleport scroll:</span> 4 uses to
                  teleport wherever you want. You will not be able to come back
                  to the den, so be sure you have everything ready before
                  departing.
                  <br />
                  <span style={robestyle}>Wizard robes:</span> Used to cast most
                  spells. Your spellbook will let you know which spells cannot
                  be cast without a garb.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section textAlign="center" textColor="red" fontSize="20px">
              Remember: Do not forget to prepare your spells.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>
        The Space Wizards Federation has given you the following tasks:
      </Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

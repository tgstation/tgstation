import { Box, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

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

const grandritualstyle = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

type GrandRitual = {
  remaining: number;
  next_area: string;
};

type Info = {
  objectives: Objective[];
  ritual: GrandRitual;
  can_change_objective: BooleanLike;
};

export const AntagInfoWizard = (props) => {
  const { data, act } = useBackend<Info>();
  const { ritual, objectives, can_change_objective } = data;

  return (
    <Window width={620} height={630} theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <Stack.Item textColor="red" fontSize="20px">
                  You are the Space Wizard!
                </Stack.Item>
                <Stack.Item>
                  <ObjectivePrintout
                    objectives={objectives}
                    titleMessage="The Space Wizard Federation has given you the following tasks:"
                    objectiveFollowup={
                      <ReplaceObjectivesButton
                        can_change_objective={can_change_objective}
                        button_title={'Declare Personal Quest'}
                        button_colour={'violet'}
                      />
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <RitualPrintout ritual={ritual} />
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

const RitualPrintout = (props: { ritual: GrandRitual }) => {
  const { ritual } = props;
  if (!ritual.next_area) {
    return null;
  }
  return (
    <Box>
      Alternately, complete the{' '}
      <span style={grandritualstyle}>Grand Ritual </span>
      by invoking a ritual circle at several nexuses of power.
      <br />
      You must complete the ritual
      <span style={grandritualstyle}> {ritual.remaining}</span> more times.
      <br />
      Your next ritual location is the
      <span style={grandritualstyle}> {ritual.next_area}</span>.
    </Box>
  );
};

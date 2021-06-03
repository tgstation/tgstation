
import { useBackend, useLocalState } from '../backend';
import { Blink, BlockQuote, Box, Dimmer, Icon, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

const teleportstyle = {
  color: 'yellow',
};

const robestyle = {
  color: 'lightblue',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
}

type Info = {
  objectives: Objective[];
};

export const WizardInfo = (props, context) => {
  return (
    <Window
      width={620}
      height={450}
      theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
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
          <Stack.Item grow>
            <Section fill title="Spellbook">
              <Stack>
                <Stack.Item>
                  You will find a list of available spells
                  in your spell book. Choose your magic arsenal carefully.<br />
                  The spellbook is bound to you, and others cannot use it.<br />
                  In your pockets you will find a teleport scroll.
                  Use it as needed.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Misc Gear">
              <Stack>
                <Stack.Item>
                  <span style={teleportstyle}>Teleport scroll:</span> 4
                  uses to teleport wherever you want.
                  You will not be able to come back to the den, so
                  be sure you have everything ready before departing.<br />
                  <span style={robestyle}>Wizard robes:</span> Used
                  to cast most spells. Your spellbook will let
                  you know which spells cannot be cast without a garb.
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
  const {
    objectives,
  } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>
        The Space Wizards Federation has given you the following tasks:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item key={objective.count}>
            #{objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};

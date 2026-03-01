import { Icon, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const ninja_emphasis = {
  color: 'red',
};

type NinjaInfo = {
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

export const AntagInfoNinja = (props) => {
  const { data } = useBackend<NinjaInfo>();
  const { objectives, can_change_objective } = data;
  return (
    <Window width={550} height={450} theme="hackerman">
      <Window.Content>
        <Icon
          size={30}
          name="spider"
          color="#003300"
          position="absolute"
          top="10%"
          left="10%"
        />
        <Section scrollable fill>
          <Stack vertical textColor="green">
            <Stack.Item textAlign="center" fontSize="20px">
              I am an elite mercenary of the Spider Clan.
              <br />A <span style={ninja_emphasis}> SPACE NINJA</span>!
            </Stack.Item>
            <Stack.Item textAlign="center" italic>
              Surprise is my weapon. Shadows are my armor. Without them, I am
              nothing.
            </Stack.Item>
            <Stack.Item>
              <Section fill>
                Your advanced ninja suit contains many powerful modules.
                <br /> It can be recharged by right clicking on station APCs or
                other power sources, in order to drain their battery.
                <br />
                Right clicking on some kinds of machines or items wearing your
                suit will hack them, to varying effect. Experiment and find out
                what you can do!
              </Section>
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout
                objectives={objectives}
                objectiveFollowup={
                  <ReplaceObjectivesButton
                    can_change_objective={can_change_objective}
                    button_title={'Adapt Mission Parameters'}
                    button_colour={'green'}
                  />
                }
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

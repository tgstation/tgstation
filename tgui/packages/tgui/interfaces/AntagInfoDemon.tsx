import { useBackend } from '../backend';
import { Box, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

const jauntstyle = {
  color: 'lightblue',
};

const injurestyle = {
  color: 'yellow',
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
  fluff: string;
  explain_attack: BooleanLike;
  objectives: Objective[];
};

export const AntagInfoDemon = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    fluff,
    objectives,
    explain_attack,
  } = data;
  return (
    <Window
      width={620}
      height={356}
      theme="syndicate">
      <Window.Content
        style={{ 'background-image': 'none' }}>
        <Stack fill>
          <Stack.Item>
            <DemonRunes />
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical width="544px" fill>
              <Stack.Item grow>
                <Section fill scrollable={objectives.length > 2}>
                  <Stack vertical>
                    <Stack.Item textAlign="center" textColor="red" fontSize="20px">
                      {fluff}
                    </Stack.Item>
                    <Stack.Item>
                      <ObjectivePrintout />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              {!!explain_attack && (
                <Stack.Item>
                  <Section fill title="Demonic Powers">
                    <Stack vertical>
                      <Stack.Item>
                        <span style={jauntstyle}>Blood Jaunt:</span> You
                        can dive in and out of blood to travel anywhere
                        you need to be. You will gain a speed boost upon
                        leaving the jaunt for surprise attacks. You can
                        drag victims you have disabled through the blood,
                        consuming them and restoring health.
                      </Stack.Item>
                      <Stack.Divider />
                      <Stack.Item>
                        <span style={injurestyle}>Monstrous strike:</span> You
                        can launch a devastating slam attack by right-clicking,
                        capable of smashing bones in one strike. Great for
                        preventing the escape of your victims, as their wounds
                        will slow them.
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <DemonRunes />
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
        It is in your nature to accomplish these goals:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item fontSize="20px" key={objective.count}>
            #{objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};

const DemonRunes = (props, context) => {
  return (
    <Section
      height="102%"
      mt="-6px"
      fill>
      {/*
      shoutout to my boy Yuktopus from Crash Bandicoot: Crash of the Titans.
      Damn, that was such a good game.
      */}
      <Box className="HellishRunes__demonrune" >
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S<br />
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S<br />
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S<br />
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S
      </Box>
    </Section>
  );
};

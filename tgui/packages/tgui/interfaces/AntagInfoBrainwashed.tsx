import { useBackend, useLocalState } from '../backend';
import { Blink, BlockQuote, Box, Dimmer, Icon, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

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

export const AntagInfoBrainwashed = (props, context) => {
  return (
    <Window
      width={400}
      height={400}
      theme="abductor">
      <Window.Content
        backgroundColor="#722e7d">
        <Icon
          size={16}
          name="flushed"
          color="#3f1945"
          position="absolute"
          top="42%"
          left="26%" />
        <Section fill>
          <Stack align="baseline" vertical fill>
            <Stack.Item fontFamily="Wingdings">
              Hey, no! Stop translating this!
            </Stack.Item>
            <Stack.Item mt={-0.25} fontSize="20px">
              Your mind reels...
            </Stack.Item>
            <Stack.Item mt={-0.25} fontSize="20px">
              It is focusing on a single purpose...
            </Stack.Item>
            <Stack.Item mt={1.5} grow >
              <ObjectivePrintout />
            </Stack.Item>
            <Stack.Item fontSize="20px">
              Follow the Directives, at any cost!
            </Stack.Item>
            <Stack.Item fontFamily="Wingdings">
              You ruined my cool font effect.
            </Stack.Item>
          </Stack>
        </Section>
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
        Your current objectives:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <>
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
            <Stack.Item textColor="red">
              This Directive must be followed.
            </Stack.Item>
          </>
        )) }
      </Stack.Item>
    </Stack>
  );
};

import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
}

type Info = {
  objectives: Objective[];
  goal: string;
  intro: string;
  honor: BooleanLike;
};

export const AntagInfoThief = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    intro,
    goal,
    honor,
  } = data;
  return (
    <Window
      width={620}
      height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <Stack.Item textColor="red" fontSize="20px">
                  {intro}
                </Stack.Item>
                <Stack.Item>
                  {goal}
                </Stack.Item>
                <Stack.Item>
                  <ObjectivePrintout />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section textAlign="center" textColor="red" fontSize="20px">
              Remember: There is {!honor && "no "}honor among thieves.
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
        These are your heisting goals for today:
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

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
  guild: string;
  policy: string;
};

export const AntagInfoThief = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    intro,
    goal,
    guild,
    policy,
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
          {!!guild && (
            <Stack.Item>
              <Section textAlign="center" textColor="green">
                This station has an established Thieves Guild, of which you
                have been invited to join. It is at the {guild}. Use it as
                a space to plan heists with other thieves, and store stolen
                goods!
              </Section>
            </Stack.Item>
          )}
          {!!policy && (
            <Stack.Item>
              <Section textAlign="center" textColor="red" fontSize="19px">
                {policy}
              </Section>
            </Stack.Item>
          )}
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

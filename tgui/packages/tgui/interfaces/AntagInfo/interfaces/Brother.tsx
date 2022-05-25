import { useBackend } from 'tgui/backend';
import { Section, Stack } from 'tgui/components';
import { BooleanLike } from 'common/react';
import { Window } from 'tgui/layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
}

type Info = {
  antag_name: string;
  objectives: Objective[];
  brothers: string;
};

export const AntagInfoBrother = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    antag_name,
    brothers,
  } = data;
  return (
    <Window
      width={620}
      height={250}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are the {antag_name} of {brothers}!
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
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
        Your objectives:
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

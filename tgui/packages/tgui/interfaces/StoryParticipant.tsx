import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type Info = {
  name: string;
  info: string;
  goal: string;
  timeout: string;
};

export const StoryParticipant = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { name, goal, timeout } = data;
  return (
    <Window width={620} height={400}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            {timeout ? (
              <Stack.Item textColor="blue" fontSize="20px">
                Time until you are sent to the station: {timeout}
              </Stack.Item>
            ) : (
              <Stack.Item />
            )}
            <Stack.Item textColor="blue" fontSize="20px">
              You are the {name}!
            </Stack.Item>
            <Stack.Item>
              <InfoPrintout />
            </Stack.Item>
            {goal !== '' ? (
              <Stack.Item>
                <GoalPrintout />
              </Stack.Item>
            ) : (
              <Stack.Item />
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const InfoPrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { info } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your backstory:</Stack.Item>
      <Stack.Item>{info}</Stack.Item>
    </Stack>
  );
};

const GoalPrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { goal } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your goal:</Stack.Item>
      <Stack.Item>{goal}</Stack.Item>
    </Stack>
  );
};

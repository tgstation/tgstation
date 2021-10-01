import { useBackend } from '../backend';
import { Box, LabeledList, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

export const CryopodConsole = (props, context) => {
  const { data } = useBackend(context);
  const { account_name } = data;

  const welcomeTitle = `Hello, ${account_name || '[REDACTED]'}!`;

  return (
    <Window title="Cryopod Console" width={400} height={480}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title={welcomeTitle}>
              This automated cryogenic freezing unit will safely store your
              corporeal form until your next assignment.
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <CrewList />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewList = (props, context) => {
  const { data } = useBackend(context);
  const { frozen_crew } = data;

  return (
    frozen_crew.length && (
      <Section
        fill
        scrollable>
        <LabeledList>
          {frozen_crew.map((person) => (
            <LabeledList.Item key={person} label={person.name}>
              {person.job}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    ) || (
      <NoticeBox>No stored crew!</NoticeBox>
    )
  );
};

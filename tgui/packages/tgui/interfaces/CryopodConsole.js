import { useBackend } from '../backend';
import { Collapsible, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const CryopodConsole = (props, context) => {
  const { data } = useBackend(context);
  const { account_name } = data;

  const welcomeTitle = `Hello, ${account_name || '[REDACTED]'}!`;

  return (
    <Window title="Cryopod Console" width={400} height={480}>
      <Window.Content>
        <Section title={welcomeTitle}>
          This automated cryogenic freezing unit will safely store your
          corporeal form until your next assignment.
        </Section>
        <CrewList />
      </Window.Content>
    </Window>
  );
};

const CrewList = (props, context) => {
  const { data } = useBackend(context);
  const { frozen_crew } = data;

  return (
    <Collapsible title="Stored Crew">
      {!frozen_crew.length ? (
        <NoticeBox>No stored crew!</NoticeBox>
      ) : (
        <Section height={10} fill scrollable>
          <LabeledList>
            {frozen_crew.map((person) => (
              <LabeledList.Item key={person} label={person.name}>
                {person.job}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      )}
    </Collapsible>
  );
};

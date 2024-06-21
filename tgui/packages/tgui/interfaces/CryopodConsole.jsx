import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

export const CryopodConsole = (props) => {
  const { data } = useBackend();
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
          <Stack.Item grow>
            <ItemList />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewList = (props) => {
  const { data } = useBackend();
  const { frozen_crew } = data;

  return (
    (frozen_crew.length && (
      <Section fill scrollable>
        <LabeledList>
          {frozen_crew.map((person) => (
            <LabeledList.Item key={person} label={person.name}>
              {person.job}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    )) || <NoticeBox>No stored crew!</NoticeBox>
  );
};

const ItemList = (props) => {
  const { act, data } = useBackend();
  const { item_ref_list, item_ref_name, item_retrieval_allowed } = data;
  if (!item_retrieval_allowed) {
    return <NoticeBox>You are not authorized for item management.</NoticeBox>;
  }
  return (
    (item_ref_list.length && (
      <Section fill scrollable>
        <LabeledList>
          {item_ref_list.map((item) => (
            <LabeledList.Item key={item} label={item_ref_name[item]}>
              <Button
                icon="exclamation-circle"
                content="Retrieve"
                color="bad"
                onClick={() => act('item_get', { item_get: item })}
              />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    )) || <NoticeBox>No stored items!</NoticeBox>
  );
};

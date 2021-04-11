import { useBackend } from '../backend';
import { Stack, Button, Section, NoticeBox, LabeledList, Collapsible } from '../components';
import { Window } from '../layouts';

export const CryopodConsole = (props, context) => {
  const { data } = useBackend(context);
  const { account_name, allow_items } = data;

  const welcomeTitle = `Hello, ${account_name || '[REDACTED]'}!`;

  return (
    <Window title="Cryopod Console" width={400} height={480}>
      <Window.Content>
        <Stack vertical>
          <Section title={welcomeTitle}>
            This automated cryogenic freezing unit will safely store your
            corporeal form until your next assignment.
          </Section>
          <CrewList />
          {!!allow_items && <ItemList />}
        </Stack>
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

const ItemList = (props, context) => {
  const { act, data } = useBackend(context);
  const { frozen_items } = data;

  const replaceItemName = (item) => {
    let itemName = item.toString();
    if (itemName.startsWith('the')) {
      itemName = itemName.slice(4, itemName.length);
    }
    return itemName.replace(/^\w/, (c) => c.toUpperCase());
  };

  return (
    <Collapsible title="Stored Items">
      {!frozen_items.length ? (
        <NoticeBox>No stored items!</NoticeBox>
      ) : (
        <>
          <Section height={12} fill scrollable>
            <LabeledList>
              {frozen_items.map((item, index) => (
                <LabeledList.Item
                  key={item}
                  label={replaceItemName(item)}
                  buttons={
                    <Button
                      icon="arrow-down"
                      content="Drop"
                      mr={1}
                      onClick={() => act('one_item', { item: index + 1 })}
                    />
                  }
                />
              ))}
            </LabeledList>
          </Section>
          <Button
            content="Drop All Items"
            color="red"
            onClick={() => act('all_items')}
          />
        </>
      )}
    </Collapsible>
  );
};

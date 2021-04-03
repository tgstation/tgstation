import { useBackend } from '../backend';
import {
  Box,
  Stack,
  Button,
  Section,
  NoticeBox,
  LabeledList,
  Collapsible,
} from '../components';

import { Window } from '../layouts';
import { logger } from '../logging';

export const CryopodConsole = (props, context) => {
  const { data } = useBackend(context);
  const { account_name, allow_items } = data;

  let welcomeTitle = `Hello, ${account_name || '[REDACTED]'}!`;

  return (
    <Window resizable title="Cryopod Console" width={400} height={500}>
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
            {frozen_crew.map((person, index) => (
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

  return (
    <Collapsible title="Stored Items">
      {!frozen_items.length ? (
        <NoticeBox>No stored items!</NoticeBox>
      ) : (
        <Fragment>
          <Section height={11} fill scrollable>
            <LabeledList>
              {frozen_items.map((item) => (
                <LabeledList.Item
                  key={item}
                  label={item.replace(/^\w/, (c) => c.toUpperCase())}
                  buttons={
                    <Button
                      icon="hand-holding"
                      content="Drop"
                      onClick={() => act('one_item', { item })}
                    />
                  }
                />
              ))}
            </LabeledList>
          </Section>
          <Button
            content="Drop All Items"
            color="red"
            onClick={() => act('all_items', {})}
          />
        </Fragment>
      )}
    </Collapsible>
  );
};

import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type byondRef = string;

type IDInfo = {
  name: string;
  points: number;
  goal: number;
};

type DMButton = {
  name?: string;
  icon?: string;
  color?: string;
  tooltip?: string;
  action_key: string;
  action_params: Record<string, string>;
};

type ImplantInfo = {
  info: Record<string, string>;
  buttons: DMButton[];
  category: string;
  ref: byondRef;
};

type Data = {
  authorized: BooleanLike;
  inserted_id: IDInfo | null;
  implants: ImplantInfo[];
};

const ImplantDisplay = (props: { implant: ImplantInfo }) => {
  const { act } = useBackend<ImplantInfo>();
  const { info, buttons, ref } = props.implant;

  return (
    <Stack vertical>
      <Stack.Item>
        <LabeledList>
          {Object.entries(info).map(([key, value]) => (
            <LabeledList.Item key={key} label={key}>
              {value}
            </LabeledList.Item>
          ))}
          {buttons.length !== 0 && (
            <LabeledList.Item label={'Options'}>
              {buttons.map((button) => (
                <Button
                  key={button.action_key}
                  icon={button.icon}
                  color={button.color}
                  tooltip={button.tooltip}
                  onClick={() =>
                    act('handle_implant', {
                      implant_ref: ref,
                      implant_action: button.action_key,
                      ...button.action_params,
                    })
                  }
                >
                  {button.name}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          <LabeledList.Divider />
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

// When given a list of implants, sorts them by category
const sortImplants = (
  implants: ImplantInfo[],
): Record<string, ImplantInfo[]> => {
  return implants.reduce((acc, implant) => {
    if (implant.category in acc) {
      acc[implant.category].push(implant);
    } else {
      acc[implant.category] = [implant];
    }
    return acc;
  }, {});
};

// Converts a category ("tracking implant") to a more readable format ("Tracking")
// Does this by capitalizing the first letter of the first word and removing the rest
const formatCategory = (category: string) => {
  const firstWord = category.split(' ')[0];
  return firstWord.charAt(0).toUpperCase() + firstWord.slice(1);
};

const AllImplantDisplay = (props: { implants: ImplantInfo[] }) => {
  const implantsByCategory: Record<string, ImplantInfo[]> = sortImplants(
    props.implants,
  );

  const [implantTab, setImplantTab] = useSharedState(
    'implantTab',
    Object.keys(implantsByCategory)[0],
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs>
          {Object.entries(implantsByCategory).map(([category, implants]) => (
            <Tabs.Tab
              key={category}
              selected={implantTab === category}
              onClick={() => setImplantTab(category)}
            >
              {formatCategory(category)}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        {implantTab && implantsByCategory && implantsByCategory[implantTab] ? (
          implantsByCategory[implantTab].map((implant) => (
            <ImplantDisplay key={implant.ref} implant={implant} />
          ))
        ) : (
          <NoticeBox>No implants detected.</NoticeBox>
        )}
      </Stack.Item>
    </Stack>
  );
};

const IdShowcase = (props: { id: IDInfo | null }) => {
  const { act } = useBackend<IDInfo>();
  const { id } = props;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <LabeledList>
          {id ? (
            <>
              <LabeledList.Item label="ID">
                <Button onClick={() => act('eject_id')} icon="eject" mr={1} />
                {id.name}
              </LabeledList.Item>
              <LabeledList.Item label="Points">
                <Button
                  onClick={() => act('reset_id')}
                  icon="times"
                  color="bad"
                  mr={1}
                />
                {id.points}
              </LabeledList.Item>
              <LabeledList.Item label="Goal">
                <Button
                  onClick={() => act('set_id_goal')}
                  icon="check"
                  mr={1}
                />
                {id.goal}
              </LabeledList.Item>
            </>
          ) : (
            <LabeledList.Item label="ID">
              <Button onClick={() => act('insert_id')}>No ID Inserted</Button>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Stack.Item>
      {!!id && (
        <Stack.Item>
          <NoticeBox>
            Space Law recommends quotas of 100 points per minute they would
            normally serve in the brig.
          </NoticeBox>
        </Stack.Item>
      )}
    </Stack>
  );
};

const ManagementConsole = () => {
  const { act, data } = useBackend<Data>();

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="ID Management">
          <IdShowcase id={data.inserted_id} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Security Implants" scrollable fill>
          <AllImplantDisplay implants={data.implants} />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox align="right" info>
          Secure Your Workspace.
          <Button
            align="right"
            icon="lock"
            color="good"
            ml={2}
            onClick={() => act('logout')}
          >
            Log Out
          </Button>
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

// I copied this from security records,
// should probably make this a generic component
const LogIn = () => {
  const { act } = useBackend<Data>();

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center" grow={2}>
          <Icon color="average" name="exclamation-triangle" size={15} />
        </Stack.Item>
        <Stack.Item align="center" grow>
          <Box color="red" fontSize="18px" bold mt={5}>
            Nanotrasen SecurityHUB
          </Box>
        </Stack.Item>
        <Stack.Item>
          <NoticeBox align="right">
            You are not logged in.
            <Button ml={2} icon="lock-open" onClick={() => act('login')}>
              Login
            </Button>
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const PrisonerManagement = () => {
  const { data } = useBackend<Data>();
  const { authorized } = data;
  return (
    <Window width={465} height={565} title="Prisoner Management">
      <Window.Content>
        {authorized ? <ManagementConsole /> : <LogIn />}
      </Window.Content>
    </Window>
  );
};

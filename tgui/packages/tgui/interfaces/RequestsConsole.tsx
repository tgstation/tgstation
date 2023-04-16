import { useBackend, useSharedState } from '../backend';
import { Box, Button, Icon, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

export type RequestsData = {
  department: string;
  emergency: string;
  messages: RequestMessage[];
  new_message_priority: number;
  silent: BooleanLike;
};

export type RequestMessage = {
  content: string;
};

export const RequestsConsole = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { department } = data;
  return (
    <Window title={department + ' Requests Console'} width={500} height={600}>
      <Window.Content>
        <RequestsConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const RequestsConsoleContent = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  return (
    <Stack vertical fill>
      <RequestsConsoleHeader />
      <RequestMainScreen />
      <RequestsConsoleFooter />
    </Stack>
  );
};
export const RequestsConsoleFooter = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { emergency, new_message_priority, silent } = data;
  return (
    <Stack.Item>
      <Button.Checkbox
        fluid
        checked={!silent}
        content={'Speaker'}
        onClick={() => act('toggle_silent')}
      />
    </Stack.Item>
  );
};
export const RequestsConsoleHeader = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { new_message_priority } = data;
  return (
    <Stack.Item>
      {!!new_message_priority && <MessageNoticeBox />}
      <EmergencyBox />
    </Stack.Item>
  );
};

export const EmergencyBox = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { emergency } = data;
  return (
    <>
      {!!emergency && (
        <NoticeBox danger>
          {emergency} has been dispatched to this location
        </NoticeBox>
      )}
      {!emergency && (
        <Stack fill>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="shield"
              content="Call Security"
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Security',
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="screwdriver-wrench"
              content="Call Engineering"
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Engineering',
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="suitcase-medical"
              content="Call Medical"
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Medical',
                })
              }
            />
          </Stack.Item>
        </Stack>
      )}
    </>
  );
};

export const MessageNoticeBox = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { new_message_priority } = data;
  return (
    <NoticeBox warning>
      You have new unread {new_message_priority == 2 && '<b>PRIORITY</b>'}
      {new_message_priority == 3 && '<b>EXTREME PRIORITY</b>'}
      messages
    </NoticeBox>
  );
};

export const RequestMainScreen = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  return (
    <Stack.Item grow>
      <Stack vertical fill>
        <Stack.Item>
          <Tabs textAlign="center" fluid>
            <Tabs.Tab
              selected={tab === 1}
              onClick={() => {
                setTab(1);
                act('clear_new_message_priority');
              }}>
              View Messages <Icon name={'envelope-open'} />
            </Tabs.Tab>
            <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
              Write Message <Icon name="pencil" />
            </Tabs.Tab>
            <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
              Make Announcement <Icon name="bullhorn" />
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Item grow={1}>
          {tab === 1 && <MessageViewTab />}
          {tab === 2 && <MessageWriteTab />}
          {tab === 2 && <AnnouncementTab />}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const MessageViewTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { messages = [] } = data;
  return (
    <Section fill scrollable>
      {!!messages.length && (
        <Stack vertical>
          {messages.map((message) => (
            <Stack.Item>{message.content}</Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

export const MessageWriteTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  return 'Message Write';
};

export const AnnouncementTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  return 'Announcement';
};

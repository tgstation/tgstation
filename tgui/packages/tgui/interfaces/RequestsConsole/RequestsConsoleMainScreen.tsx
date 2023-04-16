import { useBackend, useLocalState, useSharedState } from '../../backend';
import { BlockQuote, Box, Button, Icon, Section, Stack, Tabs, TextArea } from '../../components';
import { RequestsData } from './Types';

export const RequestMainScreen = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { can_send_announcements } = data;
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
            {!!can_send_announcements && (
              <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
                Make Announcement <Icon name="bullhorn" />
              </Tabs.Tab>
            )}
          </Tabs>
        </Stack.Item>
        <Stack.Item grow={1}>
          {tab === 1 && <MessageViewTab />}
          {tab === 2 && <MessageWriteTab />}
          {!!can_send_announcements && tab === 3 && <AnnouncementTab />}
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
            <Stack.Item>
              <BlockQuote>{message.content}</BlockQuote>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

export const MessageWriteTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const {
    hack_state,
    assistance_consoles = [],
    supply_consoles = [],
    information_consoles = [],
  } = data;
  const resetMessage = () => {
    setMessageText('');
    setPriority('normal');
    setRequestType('assistance');
  };
  const [messageText, setMessageText] = useLocalState(
    context,
    'messageText',
    ''
  );
  const [currentType, setRequestType] = useLocalState(
    context,
    'currentType',
    'assistance'
  );
  const [currentPriority, setPriority] = useLocalState(
    context,
    'currentPriority',
    'normal'
  );
  return (
    <Section>
      <Stack fill>
        <Stack.Item grow>
          <Button.Checkbox
            checked={currentType === 'assistance'}
            onClick={() => setRequestType('assistance')}>
            Request Assistance
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item grow>
          <Button.Checkbox
            checked={currentType === 'supplies'}
            onClick={() => setRequestType('supplies')}>
            Request Supplies
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item grow>
          <Button.Checkbox
            checked={currentType === 'information'}
            onClick={() => setRequestType('information')}>
            Relay Information
          </Button.Checkbox>
        </Stack.Item>
      </Stack>
      <Stack fill>
        <Stack.Item grow>
          <Button.Checkbox
            fluid
            checked={currentPriority === 'normal'}
            onClick={() => setPriority('normal')}>
            Normal Priority
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item grow>
          <Button.Checkbox
            fluid
            checked={currentPriority === 'high'}
            onClick={() => setPriority('high')}>
            High Priority
          </Button.Checkbox>
        </Stack.Item>
        {!!hack_state && (
          <Stack.Item grow>
            <Button.Checkbox
              fluid
              checked={currentType === 'extreme'}
              onClick={() => setPriority('extreme')}>
              EXTREME PRIORITY
            </Button.Checkbox>
          </Stack.Item>
        )}
      </Stack>
      <TextArea
        fluid
        height={20}
        maxLength={1025}
        multiline
        onChange={(_, value) => setMessageText(value)}
        placeholder="Type your message..."
      />
      <Box>
        <Button content={'Send'} onClick={() => act('send_message')} />
      </Box>
    </Section>
  );
};

export const AnnouncementTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  return 'Announcement';
};

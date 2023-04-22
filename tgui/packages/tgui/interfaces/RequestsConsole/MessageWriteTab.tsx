import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Dropdown, Section, Stack, TextArea } from '../../components';
import { RequestsData, RequestType, RequestPriority } from './Types';

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
    setRecipient('Pick a Recipient');
    setPriority(RequestPriority.NORMAL);
    setRequestType(RequestType.ASSISTANCE);
  };
  const [messageText, setMessageText] = useLocalState(
    context,
    'messageText',
    ''
  );
  const [requestType, setRequestType] = useLocalState(
    context,
    'requestType',
    RequestType.ASSISTANCE
  );
  const [priority, setPriority] = useLocalState(
    context,
    'priority',
    RequestPriority.NORMAL
  );
  const [recipient, setRecipient] = useLocalState(
    context,
    'recipient',
    'Pick a Recipient'
  );
  return (
    <Section>
      <Section>
        <Stack fill>
          <Stack.Item grow>
            <Button
              icon={'handshake-angle'}
              content={'Request Assistance'}
              selected={requestType === RequestType.ASSISTANCE}
              onClick={() => {
                setRecipient('Pick a Recipient');
                setRequestType(RequestType.ASSISTANCE);
              }}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              icon={'boxes-stacked'}
              content={'Request Supplies'}
              selected={requestType === RequestType.SUPPLIES}
              onClick={() => {
                setRecipient('Pick a Recipient');
                setRequestType(RequestType.SUPPLIES);
              }}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              icon={'user-secret'}
              content={'Relay Information'}
              selected={requestType === RequestType.INFORMATION}
              onClick={() => {
                setRecipient('Pick a Recipient');
                setRequestType(RequestType.INFORMATION);
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        {requestType === RequestType.ASSISTANCE && (
          <Dropdown
            width="100%"
            options={assistance_consoles.map((recipient) => recipient)}
            selected={recipient}
            onSelected={(value) => setRecipient(value)}
          />
        )}
        {requestType === RequestType.SUPPLIES && (
          <Dropdown
            width="100%"
            options={supply_consoles.map((recipient) => recipient)}
            selected={recipient}
            onSelected={(value) => setRecipient(value)}
          />
        )}
        {requestType === RequestType.INFORMATION && (
          <Dropdown
            width="100%"
            options={information_consoles.map((recipient) => recipient)}
            selected={recipient}
            onSelected={(value) => setRecipient(value)}
          />
        )}
      </Section>
      <Section>
        <Stack fill>
          <Stack.Item grow>
            <Button.Checkbox
              key={RequestPriority.NORMAL}
              fluid
              checked={priority === RequestPriority.NORMAL}
              onClick={() => setPriority(RequestPriority.NORMAL)}>
              Normal Priority
            </Button.Checkbox>
          </Stack.Item>
          <Stack.Item grow>
            <Button.Checkbox
              key={RequestPriority.HIGH}
              fluid
              checked={priority === RequestPriority.HIGH}
              onClick={() => setPriority(RequestPriority.HIGH)}>
              High Priority
            </Button.Checkbox>
          </Stack.Item>
          {!!hack_state && (
            <Stack.Item grow>
              <Button.Checkbox
                key={RequestPriority.EXTREME}
                fluid
                checked={priority === RequestPriority.EXTREME}
                onClick={() => setPriority(RequestPriority.EXTREME)}>
                EXTREME PRIORITY
              </Button.Checkbox>
            </Stack.Item>
          )}
        </Stack>
      </Section>
      <TextArea
        fluid
        height={20}
        maxLength={1025}
        multiline
        value={messageText}
        onChange={(_, value) => setMessageText(value)}
        placeholder="Type your message..."
      />
      <Section>
        <Stack fill justify="space-between">
          <Stack.Item>
            <Button
              warning
              icon="id-card"
              content={'Not verified'}
              onClick={() => act('verify_id')}
            />
            <Button
              warning
              icon="stamp"
              content={'Not stamped'}
              onClick={() => act('stamp')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="paper-plane"
              content={'Send message'}
              onClick={() => {
                if (!messageText || !recipient || !priority || !requestType)
                  return;

                act('send_message', {
                  message: messageText,
                  recipient: recipient,
                  request_type: requestType,
                  priority: priority,
                });
                resetMessage();
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Section>
  );
};

import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Input, Button, Table, NoticeBox, Box } from '../components';
import { Window } from '../layouts';

enum Screen {
  Main,
  MessageLogs,
  RequestLogs,
  Hacked,
}

type Data = {
  screen: Screen;
  status: BooleanLike;
  server_status: BooleanLike;
  auth: BooleanLike;
  password: string;
  is_malf: BooleanLike;
  error_message: string;
  success_message: string;
  notice_message: string;
  requests: Request[];
  messages: Message[];
};

type Request = {
  ref: string;
  message: string;
  stamp: string;
  sender_department: string;
  id_auth: string;
};

type Message = {
  ref: string;
  message: string;
  sender: string;
  recipient: string;
};

const RequestLogsScreen = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { requests = [] } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Requests"
          buttons={
            <Button
              content="Main Menu"
              icon="home"
              onClick={() => act('return_home')}
            />
          }>
          <Table>
            <Table.Row header>
              <Table.Cell>Delete</Table.Cell>
              <Table.Cell>Message</Table.Cell>
              <Table.Cell>Stamp</Table.Cell>
              <Table.Cell>Departament</Table.Cell>
              <Table.Cell>Authentication</Table.Cell>
            </Table.Row>
            {requests?.map((request) => (
              <Table.Row key={request.ref} className="candystripe">
                <Table.Cell>
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_request', { ref: request.ref })}
                  />
                </Table.Cell>
                <Table.Cell>{request.message}</Table.Cell>
                <Table.Cell>{request.stamp}</Table.Cell>
                <Table.Cell>{request.sender_department}</Table.Cell>
                <Table.Cell>{request.id_auth}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MessageLogsScreen = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { messages = [] } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Stored Messages"
          buttons={
            <Button
              content="Main Menu"
              icon="home"
              onClick={() => act('return_home')}
            />
          }>
          <Table>
            <Table.Row header>
              <Table.Cell>Delete</Table.Cell>
              <Table.Cell>Sender</Table.Cell>
              <Table.Cell>Recipient</Table.Cell>
              <Table.Cell>Message</Table.Cell>
            </Table.Row>
            {messages?.map((message) => (
              <Table.Row key={message.ref} className="candystripe">
                <Table.Cell>
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_message', { ref: message.ref })}
                  />
                </Table.Cell>
                <Table.Cell>{message.sender}</Table.Cell>
                <Table.Cell>{message.recipient}</Table.Cell>
                <Table.Cell>{message.message}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HackedScreen = (props, context) => {
  return (
    <Stack.Item grow>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center" grow>
          <Box color="red" fontSize="18px" bold mt={5}>
            E%*#OR: CRIT#%^CAL Ss&@STEM Fai++~|URE...
          </Box>
          <Box color="red" fontSize="18px" bold mt={5}>
            EN*bLING u&*E REB-00T ProT/.\;L...
          </Box>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const MainScreenAuth = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { status, is_malf, password } = data;
  const [auth_password, setPassword] = useLocalState(
    context,
    'input_password',
    password
  );
  return (
    <>
      <Stack.Item>
        <Section>
          <Input
            value={auth_password}
            onInput={(e, value) => setPassword(value)}
            placeholder="Password"
          />
          <Button
            content={'Logout'}
            onClick={() => act('auth', { auth_password: auth_password })}
          />
          <Button
            icon={status ? 'power-off' : 'times'}
            content={status ? 'ON' : 'OFF'}
            color={status ? 'green' : 'red'}
            onClick={() => act('turn_server')}
          />
          {is_malf === 1 && (
            <Button
              icon="terminal"
              content="Hack"
              color="red"
              disabled
              onClick={() => act('hack')}
            />
          )}
        </Section>
      </Stack.Item>
      <Table>
        <Table.Row header>
          <Table.Cell>Option</Table.Cell>
          <Table.Cell>Description</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={'View Message Logs'}
              onClick={() => act('view_message_logs')}
            />
          </Table.Cell>
          <Table.Cell>Shows all messages that have been sent</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={'View Request Console Logs'}
              onClick={() => act('view_request_logs')}
            />
          </Table.Cell>
          <Table.Cell>
            Shows all orders that were made in the cargo department
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={'Clear Message Logs'}
              onClick={() => act('clear_message_logs')}
            />
          </Table.Cell>
          <Table.Cell>Clears message logs</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={'Clear Request Console Logs'}
              onClick={() => act('clear_request_logs')}
            />
          </Table.Cell>
          <Table.Cell>Clears request console logs</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button content={'Set Custom Key'} onClick={() => act('set_key')} />
          </Table.Cell>
          <Table.Cell>Changes decryption key</Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              content={'Send Admin Message'}
              onClick={() => act('send_fake_message')}
            />
          </Table.Cell>
          <Table.Cell>Sends a custom message to the user&apos;s PDA</Table.Cell>
        </Table.Row>
      </Table>
    </>
  );
};

const MainScreenNotAuth = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { status, is_malf, password } = data;
  const [auth_password, setPassword] = useLocalState(
    context,
    'input_password',
    password
  );

  return (
    <>
      <Stack.Item>
        <Section>
          <Input
            value={auth_password}
            onInput={(e, value) => setPassword(value)}
            placeholder="Password"
          />
          <Button
            content={'Auth'}
            onClick={() => act('auth', { auth_password: auth_password })}
          />
          <Button
            icon={status ? 'power-off' : 'times'}
            content={status ? 'ON' : 'OFF'}
            color={status ? 'green' : 'red'}
            disabled
            onClick={() => act('turn_server')}
          />
          {!!is_malf && (
            <Button content="Hack" color="red" onClick={() => act('hack')} />
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Choose Option">
          <Table>
            <Table.Row header>
              <Table.Cell>Option</Table.Cell>
              <Table.Cell>Description</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Button
                  content={'Link Server'}
                  onClick={() => act('link_server')}
                />
              </Table.Cell>
              <Table.Cell>Connects to the server</Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Stack.Item>
    </>
  );
};

const MainScreen = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { auth } = data;
  return (
    <Stack fill vertical>
      {auth ? <MainScreenAuth /> : <MainScreenNotAuth />}
    </Stack>
  );
};

export const MessageMonitor = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    screen,
    error_message,
    success_message,
    notice_message,
    server_status,
  } = data;
  return (
    <Window width={700} height={400}>
      <Window.Content>
        <Stack vertical fill>
          {server_status ? (
            <>
              <Stack.Item>
                {!!error_message && (
                  <NoticeBox color="red">{error_message}</NoticeBox>
                )}
              </Stack.Item>
              <Stack.Item>
                {!!success_message && (
                  <NoticeBox color="green">{success_message}</NoticeBox>
                )}
              </Stack.Item>
              <Stack.Item grow>
                {(screen === Screen.Main && <MainScreen />) ||
                  (screen === Screen.MessageLogs && <MessageLogsScreen />) ||
                  (screen === Screen.RequestLogs && <RequestLogsScreen />) ||
                  (screen === Screen.Hacked && <HackedScreen />)}
              </Stack.Item>
              <Stack.Item>
                {!!notice_message && (
                  <NoticeBox color="yellow">{notice_message}</NoticeBox>
                )}
              </Stack.Item>
              <label>
                Reg. #514 forbids sending messages to a Head of Staff containing
                Erotic Rendering Properties.
              </label>
            </>
          ) : (
            <>
              <Stack.Item>
                <NoticeBox color="red">
                  Server not found, click button to scan the network
                </NoticeBox>
              </Stack.Item>
              <Stack.Item>
                <Button
                  content="Connect to server"
                  onClick={() => act('connect_server')}
                />
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

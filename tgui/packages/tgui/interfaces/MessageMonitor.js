import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Input, Button, Table, NoticeBox, Box } from '../components';
import { Window } from '../layouts';

const RequestLogsScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { requests } = data;
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
            {requests?.map((r) => (
              <Table.Row key={r.ref}>
                <Table.Cell>
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_request', { ref: m.ref })}
                  />
                </Table.Cell>
                <Table.Cell>{m.message}</Table.Cell>
                <Table.Cell>{r.stamp}</Table.Cell>
                <Table.Cell>{r.send_dpt}</Table.Cell>
                <Table.Cell>{r.id_auth}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MessageLogsScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { messages } = data;
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
            {messages?.map((m) => (
              <Table.Row key={m.ref}>
                <Table.Cell>
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => act('delete_message', { ref: m.ref })}
                  />
                </Table.Cell>
                <Table.Cell>{m.sender}</Table.Cell>
                <Table.Cell>{m.recipient}</Table.Cell>
                <Table.Cell>{m.message}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HackedScreen = (props, context) => {
  const { act, data } = useBackend(context);
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

const MainScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { password, status, auth, server_status, is_malf } = data;

  return (
    <Stack fill vertical>
      {server_status === 1 ? (
        <>
          <Stack.Item content="Welcome, please select an option" />
          <Stack.Item>
            <Section>
              <Input
                value={password}
                onInput={(e, value) => setPassword(value)}
                placeholder="Password"
              />
              <Button
                content={auth ? 'Logout' : 'Auth'}
                onClick={() => act('auth', { password: password })}
              />
              <Button
                content={status ? 'ON' : 'OFF'}
                color={status ? 'green' : 'red'}
                disabled={!auth ? true : false}
                onClick={() => act('turn_server')}
              />
              {is_malf ? (
                <Button
                  content="Hack"
                  color="red"
                  disabled={auth ? true : false}
                  onClick={() => act('hack')}
                />
              ) : (
                ''
              )}
            </Section>
          </Stack.Item>
        </>
      ) : (
        ''
      )}
      <Stack.Item grow>
        <Section fill scrollable title="Choose Option">
          <Table>
            <Table.Row header>
              <Table.Cell>Option</Table.Cell>
              <Table.Cell>Description</Table.Cell>
            </Table.Row>
            {server_status === 1 && auth === 1 ? (
              <>
                <Table.Row>
                  <Table.Cell>
                    <Button
                      content={'View Message Logs'}
                      onClick={() => act('view_message_logs')}
                    />
                  </Table.Cell>
                  <Table.Cell>
                    Shows all messages that have been sent
                  </Table.Cell>
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
                    <Button
                      content={'Set Custom Key'}
                      onClick={() => act('set_key')}
                    />
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
                  <Table.Cell>
                    Sends a custom message to the user&apos;s PDA
                  </Table.Cell>
                </Table.Row>
              </>
            ) : (
              <Table.Row>
                <Table.Cell>
                  <Button
                    content={'Link Server'}
                    onClick={() => act('link_server')}
                  />
                </Table.Cell>
                <Table.Cell>Connects to the server</Table.Cell>
              </Table.Row>
            )}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const MessageMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const { screen, error, succes, notice, server_status } = data;
  return (
    <Window width={700} height={400}>
      <Window.Content>
        <Stack vertical fill>
          {server_status === 1 ? (
            <>
              <Stack.Item>
                {error !== '' && <NoticeBox color="red">{error}</NoticeBox>}
              </Stack.Item>
              <Stack.Item>
                {succes !== '' && <NoticeBox color="green">{succes}</NoticeBox>}
              </Stack.Item>
              <Stack.Item grow>
                {(screen === 0 && <MainScreen />) ||
                  (screen === 1 && <MessageLogsScreen />) ||
                  (screen === 2 && <RequestLogsScreen />) ||
                  (screen === 3 && <HackedScreen />)}
              </Stack.Item>
              <Stack.Item>
                {notice !== '' && (
                  <NoticeBox color="yellow">{notice}</NoticeBox>
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

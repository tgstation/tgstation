import { useBackend, useLocalState } from '../backend';
import { createSearch } from 'common/string';
import { Box, Button, Dimmer, Icon, Section, Stack, Input } from '../components';
import { NtosWindow } from '../layouts';

const NoIDDimmer = (props, context) => {
  const { act, data } = useBackend(context);
  const { owner } = data;
  return (
    <Stack>
      <Stack.Item>
        <Dimmer>
          <Stack align="baseline" vertical>
            <Stack.Item>
              <Stack ml={-2}>
                <Stack.Item>
                  <Icon color="red" name="address-card" size={10} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item fontSize="18px">
              Please imprint an ID to continue.
            </Stack.Item>
          </Stack>
        </Dimmer>
      </Stack.Item>
    </Stack>
  );
};

export const NtosMessenger = (props, context) => {
  const { act, data } = useBackend(context);
  const { viewing_messages } = data;
  if (viewing_messages) {
    return <MessageListScreen />;
  }
  return <ContactsScreen />;
};

const ContactsScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    owner,
    ringer_status,
    sending_and_receiving,
    messengers = [],
    sortByJob,
    canSpam,
    isSilicon,
    photo,
    virus_attach,
    sending_virus,
  } = data;
  const [searchUser, setSearchUser] = useLocalState(context, 'searchUser', '');
  const search = createSearch(
    searchUser,
    (messengers) => messengers.name + messengers.job
  );
  let users =
    searchUser.length > 0 ? data.messengers.filter(search) : messengers;
  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Stack vertical>
          <Section fill textAlign="center">
            <Box bold>
              <Icon name="address-card" mr={1} />
              SpaceMessenger V6.4.8
            </Box>
            <Box italic opacity={0.3}>
              Bringing you spy-proof communications since 2467.
            </Box>
          </Section>
        </Stack>
        <Stack vertical>
          <Section fill textAlign="center">
            <Box>
              <Button
                icon="bell"
                content={ringer_status ? 'Ringer: On' : 'Ringer: Off'}
                onClick={() => act('PDA_ringer_status')}
              />
              <Button
                icon="address-card"
                content={
                  sending_and_receiving
                    ? 'Send / Receive: On'
                    : 'Send / Receive: Off'
                }
                onClick={() => act('PDA_sAndR')}
              />
              <Button
                icon="bell"
                content="Set Ringtone"
                onClick={() => act('PDA_ringSet')}
              />
              <Button
                icon="comment"
                content="View Messages"
                onClick={() => act('PDA_viewMessages')}
              />
              <Button
                icon="sort"
                content={`Sort by: ${sortByJob ? 'Job' : 'Name'}`}
                onClick={() => act('PDA_changeSortStyle')}
              />
              {!!virus_attach && (
                <Button
                  icon="bug"
                  color="bad"
                  content={`Attach Virus: ${sending_virus ? 'Yes' : 'No'}`}
                  onClick={() => act('PDA_toggleVirus')}
                />
              )}
            </Box>
          </Section>
        </Stack>
        {!!photo && (
          <Stack vertical mt={1}>
            <Section fill textAlign="center">
              <Icon name="camera" mr={1} />
              Current Photo
            </Section>
            <Section align="center">
              <Button onClick={() => act('PDA_clearPhoto')}>
                <Box mt={1} as="img" src={photo ? photo : null} />
              </Button>
            </Section>
          </Stack>
        )}
        <Stack vertical mt={1}>
          <Section fill textAlign="center">
            <Icon name="address-card" mr={1} />
            Detected Messengers
            <Input
              width="220px"
              placeholder="Search by name or job..."
              value={searchUser}
              onInput={(e, value) => setSearchUser(value)}
              mx={1}
              ml={27}
            />
          </Section>
        </Stack>
        <Stack vertical mt={1}>
          <Section fill>
            <Stack vertical>
              {users.length === 0 && 'No users found'}
              {users.map((messenger) => (
                <Button
                  key={messenger.ref}
                  fluid
                  onClick={() =>
                    act('PDA_sendMessage', {
                      name: messenger.name,
                      job: messenger.job,
                      ref: messenger.ref,
                    })
                  }>
                  {messenger.name} ({messenger.job})
                </Button>
              ))}
            </Stack>
            {!!canSpam && (
              <Button
                fluid
                mt={1}
                content="Send to all..."
                onClick={() => act('PDA_sendEveryone')}
              />
            )}
          </Section>
        </Stack>
        {!owner && !isSilicon && <NoIDDimmer />}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const MessageListScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { messages = [] } = data;
  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Stack vertical>
          <Section fill>
            <Button
              icon="arrow-left"
              content="Back"
              onClick={() => act('PDA_viewMessages')}
            />
            <Button
              icon="trash"
              content="Clear Messages"
              onClick={() => act('PDA_clearMessages')}
            />
          </Section>
          {messages.map((message) => (
            <Stack vertical key={message} mt={1}>
              <Section textAlign="left">
                <Box italic opacity={0.5} mb={1}>
                  {message.outgoing ? '(OUTGOING)' : '(INCOMING)'}
                </Box>
                {message.outgoing ? (
                  <Box bold>{message.name + ' (' + message.job + ')'}</Box>
                ) : (
                  <Button
                    transparent
                    content={message.name + ' (' + message.job + ')'}
                    onClick={() =>
                      act('PDA_sendMessage', {
                        name: message.name,
                        job: message.job,
                        ref: message.ref,
                      })
                    }
                  />
                )}
              </Section>
              <Section fill mt={-1}>
                <Box italic>{message.contents}</Box>
                {!!message.photo && <Box as="img" src={message.photo} mt={1} />}
              </Section>
            </Stack>
          ))}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

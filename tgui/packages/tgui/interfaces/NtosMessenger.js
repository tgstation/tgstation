/* eslint-disable unused-imports/no-unused-imports */
import { useBackend } from '../backend';
import { Box, Button, Dimmer, Icon, Input, Section, Stack } from '../components';
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
                  <Icon
                    color="red"
                    name="address-card"
                    size={10}
                  />
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
  const {
    owner,
    messages = ["hi"],
    ringerStatus,
    sAndR,
    messengers = [],
    viewingMessages,
    sortByJob,
    canSpam,
  } = data;
  if (viewingMessages) {
    return (
      <NtosWindow width={600} height={800}>
        <NtosWindow.Content>
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
            {messages.map(message => (
              <Stack vertical key={message} mt={1}>
                <Section fill textAlign="left">
                  <Box italic opacity={0.5}>
                    {message.outgoing ? (
                      "(OUTGOING)"
                    ) : (
                      "(INCOMING)"
                    )}
                  </Box>
                  {message.outgoing ? (
                    <Box bold>
                      {message.name + " (" + message.job + ")"}
                    </Box>
                  ) : (
                    <Button transparent
                      content={message.name + " (" + message.job + ")"}
                      onClick={() => act('PDA_sendMessage', {
                        name: message.name,
                        job: message.job,
                        ref: message.ref,
                      })}
                    />
                  )}
                </Section>
                <Section mt={-1}>
                  <Box italic>
                    {message.contents}
                  </Box>
                </Section>
              </Stack>
            ))}
          </Stack>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }
  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content>
        <Stack vertical>
          <Section fill textAlign="center">
            <Box bold>
              <Icon name="address-card" mr={1} />
              SpaceMessenger V6.4.7
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
                content={ringerStatus ? 'Ringer: On' : 'Ringer: Off'}
                onClick={() => act('PDA_ringerStatus')}
              />
              <Button
                icon="address-card"
                content={sAndR ? "Send / Receive: On" : "Send / Receive: Off"}
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
                content={sortByJob ? "Sort by: Job" : "Sort by: Name"}
                onClick={() => act('PDA_changeSortStyle')}
              />
            </Box>
          </Section>
        </Stack>
        <Stack vertical mt={1}>
          <Section fill textAlign="center">
            <Icon name="address-card" mr={1} />
            Detected Messengers
          </Section>
        </Stack>
        <Stack vertical mt={1}>
          <Section fill>
            <Stack vertical>
              {messengers.map(messenger => (
                <Button
                  key={messenger.ref}
                  fluid
                  content={messenger.name + " (" + messenger.job + ")"}
                  onClick={() => act('PDA_sendMessage', {
                    name: messenger.name,
                    job: messenger.job,
                    ref: messenger.ref,
                  })}
                />
              ))}
            </Stack>
            {!!canSpam && (
              <Button
                fluid
                content="Send to all..."
                onClick={() => act('PDA_sendEveryone')}
              />
            )}
          </Section>
        </Stack>
        {!owner && (
          <NoIDDimmer />
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

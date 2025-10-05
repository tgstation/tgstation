import {
  Box,
  Button,
  Dimmer,
  Icon,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

// byond defines for the program state
const CLIENT_ONLINE = 2;
const CLIENT_AWAY = 1;
const CLIENT_OFFLINE = 0;

const NoChannelDimmer = (props) => {
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Stack ml={-2}>
            <Stack.Item>
              <Icon color="green" name="grin-beam" size={10} />
            </Stack.Item>
            <Stack.Item mt={-8}>
              <Icon name="comment-dots" size={10} />
            </Stack.Item>
            <Stack.Item ml={-1}>
              <Icon color="green" name="smile" size={10} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item fontSize="18px">
          Click a channel to start chatting!
        </Stack.Item>
        <Stack.Item fontSize="15px">
          (If you&apos;re new, you may want to set your name in the bottom
          left!)
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const NtosNetChat = (props) => {
  const { act, data } = useBackend();
  const {
    title,
    can_admin,
    adminmode,
    authed,
    username,
    active_channel,
    is_operator,
    strong,
    selfref,
    all_channels = [],
    clients = [],
    messages = [],
  } = data;
  const in_channel = active_channel !== null;
  const authorized = authed || adminmode;
  // This list has clients ordered by operator>status>alphabetical
  const displayed_clients = clients.sort((clientA, clientB) => {
    return (
      clientB.operator - clientA.operator ||
      clientB.status - clientA.status ||
      clientB.name < clientA.name
    );
  });
  const client_color = (client) => {
    if (client.operator) {
      return 'green';
    }
    if (client.online) {
      return 'white';
    }
    if (client.away) {
      return 'yellow';
    } else {
      return 'label';
    }
  };
  // client from this computer!
  const this_client = clients.find((client) => client.ref === selfref);
  return (
    <NtosWindow width={1000} height={675}>
      <NtosWindow.Content>
        <Stack fill>
          <Stack.Item>
            <Section fill>
              <Stack vertical fill>
                <Stack.Item grow>
                  <Button.Input
                    fluid
                    buttonText="New Channel..."
                    onCommit={(value) =>
                      act('PRG_newchannel', {
                        new_channel_name: value,
                      })
                    }
                  />
                  {all_channels.map((channel) => (
                    <Button
                      fluid
                      key={channel.chan}
                      content={channel.chan}
                      selected={channel.id === active_channel}
                      color="transparent"
                      onClick={() =>
                        act('PRG_joinchannel', {
                          id: channel.id,
                        })
                      }
                    />
                  ))}
                </Stack.Item>
                <Stack.Item>
                  <Box>Username:</Box>
                  <Button.Input
                    fluid
                    mt={1}
                    buttonText={`${username}...`}
                    value={username}
                    onCommit={(value) =>
                      act('PRG_changename', {
                        new_name: value,
                      })
                    }
                  />
                  {!!can_admin && (
                    <Button
                      fluid
                      bold
                      content={`ADMIN MODE: ${adminmode ? 'ON' : 'OFF'}`}
                      color={adminmode ? 'bad' : 'good'}
                      onClick={() => act('PRG_toggleadmin')}
                    />
                  )}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow={4}>
            <Stack fill vertical g={0}>
              <Stack.Item grow>
                <Section scrollable fill>
                  {(in_channel &&
                    (authorized ? (
                      messages.map((message) => (
                        <Box key={message.key}>{message.msg}</Box>
                      ))
                    ) : (
                      <Box textAlign="center">
                        <Icon
                          name="exclamation-triangle"
                          mt={4}
                          fontSize="40px"
                        />
                        <Box mt={1} bold fontSize="18px">
                          THIS CHANNEL IS PASSWORD PROTECTED
                        </Box>
                        <Box mt={1}>INPUT PASSWORD TO ACCESS</Box>
                      </Box>
                    ))) || <NoChannelDimmer />}
                </Section>
              </Stack.Item>
              {!!in_channel && (
                <Input
                  backgroundColor={this_client?.muted && 'red'}
                  height="22px"
                  placeholder={
                    (this_client?.muted && 'You are muted!') ||
                    `Message ${title}`
                  }
                  fluid
                  disabled={this_client?.muted}
                  selfClear
                  mt={1}
                  onEnter={(value) =>
                    act('PRG_speak', {
                      message: value,
                    })
                  }
                />
              )}
            </Stack>
          </Stack.Item>
          {!!in_channel && (
            <>
              <Stack.Divider />
              <Stack.Item grow={2}>
                <Stack vertical fill>
                  <Stack.Item grow>
                    <Section scrollable fill>
                      <Stack vertical>
                        {displayed_clients.map((client) => (
                          <Stack height="18px" fill key={client.name}>
                            <Stack.Item
                              basis={0}
                              grow
                              color={client_color(client)}
                            >
                              {client.name}
                            </Stack.Item>
                            {client !== this_client && (
                              <>
                                <Stack.Item>
                                  <Button
                                    disabled={this_client?.muted}
                                    compact
                                    icon="bullhorn"
                                    tooltip={
                                      (!this_client?.muted && 'Ping') ||
                                      'You are muted!'
                                    }
                                    tooltipPosition="left"
                                    onClick={() =>
                                      act('PRG_ping_user', {
                                        ref: client.ref,
                                      })
                                    }
                                  />
                                </Stack.Item>
                                {!!is_operator && (
                                  <Stack.Item>
                                    <Button
                                      compact
                                      icon={
                                        (!client.muted && 'volume-up') ||
                                        'volume-mute'
                                      }
                                      color={
                                        (!client.muted && 'green') || 'red'
                                      }
                                      tooltip={
                                        (!client.muted && 'Mute this User') ||
                                        'Unmute this User'
                                      }
                                      tooltipPosition="left"
                                      onClick={() =>
                                        act('PRG_mute_user', {
                                          ref: client.ref,
                                        })
                                      }
                                    />
                                  </Stack.Item>
                                )}
                              </>
                            )}
                          </Stack>
                        ))}
                      </Stack>
                    </Section>
                  </Stack.Item>
                  <Section>
                    <Stack vertical g={0.5}>
                      <Stack.Item>Settings for {title}:</Stack.Item>
                      {!!(in_channel && authorized) && (
                        <>
                          <Button.Input
                            fluid
                            buttonText="Save log as..."
                            onCommit={(value) =>
                              act('PRG_savelog', {
                                log_name: value,
                              })
                            }
                          />
                          <Button.Confirm
                            fluid
                            content="Leave Channel"
                            onClick={() => act('PRG_leavechannel')}
                          />
                        </>
                      )}
                      {!!(is_operator && authed) && (
                        <>
                          <Button.Confirm
                            fluid
                            disabled={strong}
                            content="Delete Channel"
                            onClick={() => act('PRG_deletechannel')}
                          />
                          <Button.Input
                            fluid
                            disabled={strong}
                            buttonText="Rename Channel..."
                            onCommit={(value) =>
                              act('PRG_renamechannel', {
                                new_name: value,
                              })
                            }
                          />
                          <Button.Input
                            fluid
                            buttonText="Set Password..."
                            onCommit={(value) =>
                              act('PRG_setpassword', {
                                new_password: value,
                              })
                            }
                          />
                        </>
                      )}
                    </Stack>
                  </Section>
                </Stack>
              </Stack.Item>
            </>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

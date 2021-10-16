import { useBackend } from '../backend';
import { Box, Button, Dimmer, Icon, Input, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

// byond defines for the program state
const CLIENT_ONLINE = 2;
const CLIENT_AWAY = 1;
const CLIENT_OFFLINE = 0;

const STATUS2TEXT = {
  0: "Offline",
  1: "Away",
  2: "Online",
};

const NoChannelDimmer = (props, context) => {
  const { act, data } = useBackend(context);
  const { owner } = data;
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Stack ml={-2}>
            <Stack.Item>
              <Icon
                color="green"
                name="grin-beam"
                size={10}
              />
            </Stack.Item>
            <Stack.Item mt={-8}>
              <Icon
                name="comment-dots"
                size={10}
              />
            </Stack.Item>
            <Stack.Item ml={-1}>
              <Icon
                color="green"
                name="smile"
                size={10}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item fontSize="18px">
          Click a channel to start chatting!
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const NtosNetTeamChat = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    adminmode,
    authed,
    active_channel,
    is_operator,
    auto_scroll,
    strong,
    selfref,
    all_channels = [],
    clients = [],
    messages = [],
  } = data;
  const in_channel = (active_channel !== null);
  const authorized = (authed || adminmode);
  // this list has cliented ordered from their status. online > away > offline
  const displayed_clients = clients.sort((clientA, clientB) => {
    if (clientA.operator) {
      return -1;
    }
    if (clientB.operator) {
      return 1;
    }
    return clientB.status - clientA.status;
  });
  const client_color = (client) => {
    if (client.operator) {
      return "green";
    }
    switch (client.status) {
      case CLIENT_ONLINE:
        return "white";
      case CLIENT_AWAY:
        return "yellow";
      case CLIENT_OFFLINE:
      default:
        return "label";
    }
  };
  // client from this computer!
  const this_client = clients.find(client => client.ref === selfref);
  return (
    <NtosWindow
      width={1200}
      height={675}>
      <NtosWindow.Content>
        <Stack fill>
          <Stack.Item>
            <Section fill>
              <Stack vertical fill>
                <Stack.Item grow>
                  {all_channels.map(channel => (
                    <Button
                      fluid
                      key={channel.chan}
                      content={channel.chan}
                      selected={channel.id === active_channel}
                      color="transparent"
                      onClick={() => act('PRG_joinchannel', {
                        id: channel.id,
                      })} />
                  ))}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow={5}>
            <Stack vertical fill>
              <Stack.Item grow>
                <SectionAutoScroll scrollable fill doAuto={!!auto_scroll}>
                  {in_channel && (
                    authorized ? (
                      messages.map(message => (
                        <Box
                          key={message.msg}>
                          {message.msg}
                        </Box>
                      ))
                    ) : (
                      <Box
                        textAlign="center">
                        <Icon
                          name="exclamation-triangle"
                          mt={4}
                          fontSize="40px" />
                        <Box
                          mt={1}
                          bold
                          fontSize="18px">
                          THIS CHANNEL IS PASSWORD PROTECTED
                        </Box>
                        <Box mt={1}>
                          INPUT PASSWORD TO ACCESS
                        </Box>
                      </Box>
                    )
                  ) || (
                    <NoChannelDimmer />
                  )}
                </SectionAutoScroll>
              </Stack.Item>
              {!!in_channel && (
                <Input
                  backgroundColor={(this_client && this_client.muted) && "red"}
                  height="22px"
                  placeholder={(this_client && this_client.muted)
                    && "You are muted!" || "Message "+title}
                  fluid
                  selfClear
                  mt={1}
                  onEnter={(e, value) => act('PRG_speak', {
                    message: value,
                  })} />
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
                        {displayed_clients.map(client => (
                          <Stack height="18px" fill key={client.name}>
                            <Stack.Item
                              basis={0}
                              grow
                              color={client_color(client)}>
                              {client.name}
                            </Stack.Item>
                            {client !== this_client && !!is_operator && (
                              <>
                                <Stack.Item>
                                  <Button
                                    disabled={this_client.muted}
                                    compact
                                    icon="bullhorn"
                                    tooltip={!this_client.muted
                                      && "Ping" || "You are muted!"}
                                    tooltipPosition="left"
                                    onClick={() => act('PRG_ping_user', {
                                      ref: client.ref,
                                    })} />
                                </Stack.Item>
                                <Stack.Item>
                                  <Button
                                    compact
                                    icon={!client.muted
                                      && "volume-up" || "volume-mute"}
                                    color={!client.muted
                                      && "green" || "red"}
                                    tooltip={!client.muted
                                      && "Mute this User" || "Unmute this User"}
                                    tooltipPosition="left"
                                    onClick={() => act('PRG_mute_user', {
                                      ref: client.ref,
                                    })} />
                                </Stack.Item>
                              </>
                            )}
                          </Stack>
                        ))}
                      </Stack>
                    </Section>
                  </Stack.Item>
                  <Button.Checkbox
                    checked={auto_scroll}
                    onClick={() => act('PRG_auto_scroll')}>
                    Auto scroll
                  </Button.Checkbox>
                  {!!(is_operator && authed) && (
                    <Section>
                      <Stack.Item mb="8px">
                        Settings for {title}:
                      </Stack.Item>
                      <Stack.Item>
                        <Button.Input
                          fluid
                          disabled={strong}
                          content="Rename Channel..."
                          onCommit={(e, value) => act('PRG_renamechannel', {
                            new_name: value,
                          })} />
                      </Stack.Item>
                    </Section>
                  )}
                </Stack>
              </Stack.Item>
            </>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};


export class SectionAutoScroll extends Section {
  componentDidUpdate() {
    if (this.props.doAuto) {
      this.scrollableRef.current
        .scrollTop = this.scrollableRef.current.scrollHeight;
    }
  }
}

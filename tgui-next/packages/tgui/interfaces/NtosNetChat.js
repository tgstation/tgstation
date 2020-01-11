import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section, Input, Table, Flex } from '../components';
import { Fragment } from 'inferno';

export const NtosNetChat = props => {
  const { act, data } = useBackend(props);

  const {
    adminmode,
    authed,
    username,
    active_channel,
    all_channels = [],
    clients = [],
    messages = [],
  } = data;

  return (
    <Section
      height="600px">
      <Table
        height="580px">
        <Table.Row>
          <Table.Cell
            verticalAlign="top"
            style={{
              width: '200px',
            }}>
            <Box
              height="537px"
              overflowY="scroll">
              <Button.Input
                fluid
                content="New Channel..."
                onCommit={(e, value) => act('PRG_newchannel', {
                  new_channel_name: value,
                })} />
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
            </Box>
            <Button.Input
              fluid
              mt={1}
              content={username + '...'}
              onCommit={(e, value) => act('PRG_changename', {
                new_name: value,
              })} />
            <Button
              fluid
              bold
              content={"ADMIN MODE: " + (adminmode ? 'ON' : 'OFF')}
              color={adminmode ? 'bad' : 'good'}
              onClick={() => act('PRG_toggleadmin')} />
          </Table.Cell>
          <Table.Cell>
            <Box
              height="560px"
              overflowY="scroll">
              {messages.map(message => (
                <Box
                  key={message.msg}>
                  {message.msg}
                </Box>
              ))}
            </Box>
            <Input
              fluid
              selfClear
              mt={1}
              onEnter={(e, value) => act('PRG_speak', {
                message: value,
              })} />
          </Table.Cell>
          <Table.Cell
            verticalAlign="top"
            style={{
              width: '150px',
            }}>
            <Box
              height="477px"
              overflowY="scroll">
              {clients.map(client => (
                <Box key={client.name}>
                  {client.name}
                </Box>
              ))}
            </Box>
            {active_channel !== null && (
              <Fragment>
                <Button.Input
                  fluid
                  content="Save log..."
                  defaultValue="new_log"
                  onCommit={(e, value) => act('PRG_savelog', {
                    log_name: value,
                  })} />
                <Button.Confirm
                  fluid
                  content="Leave Channel"
                  onClick={() => act('PRG_leavechannel')} />
              </Fragment>
            )}
            {!!authed && (
              <Fragment>
                <Button.Confirm
                  fluid
                  content="Delete Channel"
                  onClick={() => act('PRG_deletechannel')} />
                <Button.Input
                  fluid
                  content="Rename Channel..."
                  onCommit={(e, value) => act('PRG_renamechannel', {
                    new_name: value,
                  })} />
                <Button.Input
                  fluid
                  content="Set Password..."
                  onCommit={(e, value) => act('PRG_setpassword', {
                    new_password: value,
                  })} />
              </Fragment>
            )}
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

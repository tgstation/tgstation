import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section, Input, Table, Flex } from '../components';
import { Fragment } from 'inferno';

export const NtosNetChat = props => {
  const { act, data } = useBackend(props);

  const {
    adminmode,
    all_channels = [],
    clients = [],
    messages = [],
  } = data;

  return (
    <Section
      title="test"
      minHeight="600px" bottom="0px">
        <Box height="100%" backgroundColor="#0000FF">
          test
        </Box>
        {/*
      <Table backgroundColor="#0000FF" height="100%" bottom="0px">
        <Table.Row height="100%" bottom="0px">
          <Table.Cell
            style={{
              width: '200px',
            }}>
            <Box>
              <Button
                fluid
                content="Generate Test Channel"
                onClick={() => act('PRG_newchannel', {
                  new_channel_name: 'Test Channel',
                })}
              />
              {all_channels.map(channel => (
                <Button
                  fluid
                  key={channel.chan}
                  content={channel.chan}
                  color="transparent"
                  onClick={() => act('PRG_joinchannel', {
                    id: channel.id,
                  })}
                />
              ))}
            </Box>
          </Table.Cell>
          <Table.Cell height="100%">
            <Flex height="100%" direction="column">
              <Flex.Item grow={1}>
                {messages.map(message => (
                  <Box
                    key={message.msg}>
                    {message.msg}
                  </Box>
                ))}
              </Flex.Item>
              <Flex.Item>
                <Input
                  fluid
                  onChange={(e, value) => act('PRG_speak', {
                    message: value,
                  })}
                />
              </Flex.Item>
            </Flex>
          </Table.Cell>
          <Table.Cell
            style={{
              width: '150px',
            }}>
            <Box>
              {clients.map(client => (
                <Box key={client.name}>
                  {client.name}
                </Box>
              ))}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
              */}
    </Section>
  );
};

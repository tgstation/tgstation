import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section, Input, Table } from '../components';
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
      minHeight="600px"
    >
      <Table>
        <Table.Row>
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
          <Table.Cell>
            <Box height="100%">
              {messages.map(message => (
                <Box
                  key={message.msg}>
                  {message.msg}
                </Box>
              ))}
            </Box>
            <Input
              fluid
              onChange={(e, value) => act('PRG_speak', {
                message: value,
              })}
            />
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
    </Section>
  );
};

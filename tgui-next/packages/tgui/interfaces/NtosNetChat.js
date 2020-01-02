import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section } from '../components';
import { Fragment } from 'inferno';

export const NtosNetChat = props => {
  const { act, data } = useBackend(props);

  const {
    adminmode,
    all_channels = [],
  } = data;

  return (
    <Section>
      <Grid>
        <Grid.Column>
          <Box>
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
        </Grid.Column>
        <Grid.Column>
          <Box>

          </Box>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

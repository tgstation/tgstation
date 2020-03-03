import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Grid, NoticeBox, Section, LabeledList } from '../components';

export const ExosuitConsole = props => {
  const { act, data } = useBackend(props);
  const {
    mechs = [],
  } = data;

  if (!mechs.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">
          No exosuits detected
        </NoticeBox>
      </Section>
    );
  }

  return (
    <Section>
      {mechs.map(mech => (
        <Section
          key={mech.tracker_ref}
          title={mech.name}
          buttons={(
            <Fragment>
              <Button
                icon="envelope"
                content="Send Message"
                onClick={() => act('send_message', {
                  tracker_ref: mech.tracker_ref,
                })} />
              <Button
                icon="wifi"
                content="EMP Pulse"
                color="bad"
                onClick={() => act('shock', {
                  tracker_ref: mech.tracker_ref,
                })} />
            </Fragment>
          )}>
          <Grid>
            <Grid.Column size="0.6">
              <LabeledList>
                <LabeledList.Item label="Status">
                  <Box color={mech.integrity <= 30
                    ? 'bad'
                    : mech.integrity <= 70
                      ? 'average'
                      : 'good'}>
                    {mech.integrity}%
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Charge">
                  <Box color={mech.charge <= 30
                    ? 'bad'
                    : mech.charge <= 70
                      ? 'average'
                      : 'good'}>
                    {mech.charge}%
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Airtank">
                  {mech.airtank} kPA
                </LabeledList.Item>
                {!!mech.cargo_space && (
                  <LabeledList.Item label="Used Cargo Space">
                    <Box color={mech.cargo_space <= 30
                      ? 'bad'
                      : mech.cargo_space <= 70
                        ? 'average'
                        : 'good'}>
                      {mech.cargo_space}%
                    </Box>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Grid.Column>
            <Grid.Column>
              <LabeledList>
                <LabeledList.Item label="Pilot">
                  {mech.pilot ? mech.pilot : "None"}
                </LabeledList.Item>
                <LabeledList.Item label="Location">
                  {mech.location}
                </LabeledList.Item>
                <LabeledList.Item label="Active Equipment">
                  {mech.active_equipment ? mech.active_equipment : "None"}
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
          </Grid>
        </Section>
      ))}
    </Section>
  );
};

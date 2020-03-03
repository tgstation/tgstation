import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, NoticeBox, Section, LabeledList } from '../components';

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
                content={mech.emp_recharging ? "EMP Pulse" : "Recharging..."}
                color="bad"
                disabled={mech.emp_recharging}
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
                <LabeledList.Item label="Air">
                  <AnimatedNumber
                    value={mech.airtank}
                    format={value => toFixed(value, 2)} />
                {' kPa'}
                </LabeledList.Item>
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
                {!!mech.cargo_space && (
                  <LabeledList.Item label="Cargo Load">
                    <Box color={mech.cargo_space <= 30
                      ? 'good'
                      : mech.cargo_space <= 70
                        ? 'average'
                        : 'bad'}>
                      {mech.cargo_space}%
                    </Box>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Grid.Column>
          </Grid>
        </Section>
      ))}
    </Section>
  );
};

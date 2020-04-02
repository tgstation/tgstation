import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, NoticeBox, Section, LabeledList } from '../components';

export const ExosuitControlConsole = props => {
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

  return mechs.map(mech => {
    return (
      <Section
        key={mech.tracker_ref}
        title={mech.name}
        buttons={(
          <Fragment>
            <Button
              icon="envelope"
              content="Send Message"
              disabled={!mech.pilot}
              onClick={() => act('send_message', {
                tracker_ref: mech.tracker_ref,
              })} />
            <Button
              icon="wifi"
              content={mech.emp_recharging ? "Recharging..." : "EMP Burst"}
              color="bad"
              disabled={mech.emp_recharging}
              onClick={() => act('shock', {
                tracker_ref: mech.tracker_ref,
              })} />
          </Fragment>
        )}>
        <LabeledList>
          <LabeledList.Item label="Integrity">
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
              {typeof mech.charge === 'number'
                ? mech.charge + "%"
                : "Not Found"}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Airtank">
            {typeof mech.airtank === 'number'
              ? <AnimatedNumber
                value={mech.airtank}
                format={value => toFixed(value, 2) + ' kPa'} />
              : "Not Equipped"}
          </LabeledList.Item>
          <LabeledList.Item label="Pilot">
            {mech.pilot || "None"}
          </LabeledList.Item>
          <LabeledList.Item label="Location">
            {mech.location || "Unknown"}
          </LabeledList.Item>
          <LabeledList.Item label="Active Equipment">
            {mech.active_equipment || "None"}
          </LabeledList.Item>
          {mech.cargo_space >= 0 && (
            <LabeledList.Item label="Used Cargo Space">
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
      </Section>
    );
  });
};

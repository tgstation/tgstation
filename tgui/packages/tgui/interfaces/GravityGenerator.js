import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';

export const GravityGenerator = props => {
  const { act, data } = useBackend(props);
  const {
    breaker,
    charge_count,
    charging_state,
    on,
    operational,
  } = data;

  if (!operational) {
    return (
      <Section>
        <NoticeBox textAlign="center">
          No data available
        </NoticeBox>
      </Section>
    );
  }

  return (
    <Fragment>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button
              icon={breaker ? 'power-off' : 'times'}
              content={breaker ? 'On' : 'Off'}
              selected={breaker}
              disabled={!operational}
              onClick={() => act('gentoggle')} />
          </LabeledList.Item>
          <LabeledList.Item label="Gravity Charge">
            <ProgressBar
              value={charge_count / 100}
              ranges={{
                good: [0.7, Infinity],
                average: [0.3, 0.7],
                bad: [-Infinity, 0.3],
              }} />
          </LabeledList.Item>
          <LabeledList.Item label="Charge Mode">
            {charging_state === 0 && (
              on && (
                <Box color="good">
                  Fully Charged
                </Box>
              ) || (
                <Box color="bad">
                  Not Charging
                </Box>
              ))}
            {charging_state === 1 && (
              <Box color="average">
                Charging
              </Box>
            )}
            {charging_state === 2 && (
              <Box color="average">
                Discharging
              </Box>
            )}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {operational && charging_state !== 0 && (
        <NoticeBox textAlign="center">
          WARNING - Radiation detected
        </NoticeBox>
      )}
      {operational && charging_state === 0 && (
        <NoticeBox textAlign="center">
          No radiation detected
        </NoticeBox>
      )}
    </Fragment>
  );
};

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
  return (
    <Fragment>
      <Section>
        {!operational && (
          <NoticeBox>No data available</NoticeBox>
        ) || (
          <LabeledList>
            <LabeledList.Item
              label="Status"
              buttons={(
                <Button
                  icon={breaker ? 'power-off' : 'times'}
                  content={breaker ? 'Online' : 'Offline'}
                  selected={breaker}
                  disabled={!operational}
                  onClick={() => act('gentoggle')} />
              )}>
              <Box
                color={on ? 'good' : 'bad'}>
                {on ? 'Powered' : 'Unpowered'}
              </Box>
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
            {charging_state !== 0 && (
              <LabeledList.Item label="Charge Mode">
                {charging_state === 1 && (
                  <NoticeBox>Charging...</NoticeBox>
                ) || charging_state === 2 && (
                  <NoticeBox>Discharging...</NoticeBox>
                )}
              </LabeledList.Item>
            )}
          </LabeledList>
        )}
      </Section>
      {operational && charging_state !== 0 && (
        <Section>
          <NoticeBox textAlign="center">
            WARNING - Radiation detected
          </NoticeBox>
        </Section>
      ) || (
        ""
      )}
    </Fragment>
  );
};

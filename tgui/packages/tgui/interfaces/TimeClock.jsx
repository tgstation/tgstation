import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TimeClock = (props) => {
  const { act, data } = useBackend();
  const {
    inserted_id,
    insert_id_cooldown,
    id_holder_name,
    id_job_title,
    station_alert_level,
    current_time,
    clock_status,
  } = data;

  return (
    <Window title={'Time Clock'} width={500} height={250} resizable>
      <Window.Content>
        <Section>
          <Box textAlign="center" fontSize="15px">
            Station Time : <b>{current_time}</b>
          </Box>
          <Box textAlign="center" fontSize="15px">
            Current Alert Level : <b>{station_alert_level}</b>
          </Box>
        </Section>
        {inserted_id ? (
          <>
            <Section title={false}>
              <LabeledList>
                <LabeledList.Item label="ID Holder">
                  {id_holder_name}
                </LabeledList.Item>
                <LabeledList.Item label="Current Job">
                  {id_job_title}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Box>
              <Button
                width="95%"
                disabled={insert_id_cooldown}
                onClick={() => act('clock_in_or_out')}
              >
                <center>{clock_status ? 'Clock In' : 'Clock Out'} </center>
              </Button>
              <Button icon="eject" onClick={() => act('eject_id')} />
            </Box>
          </>
        ) : (
          <Section title={false}>
            {' '}
            <Box fontSize="18px">
              <center>
                <b> Insert an ID to begin!</b>
              </center>
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

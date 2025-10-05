import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ExosuitControlConsole = (props) => {
  const { act, data } = useBackend();
  const { mechs = [] } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        {mechs.length === 0 && <NoticeBox>No exosuits detected</NoticeBox>}
        {mechs.map((mech) => (
          <Section
            key={mech.tracker_ref}
            title={mech.name}
            buttons={
              <>
                <Button
                  icon="envelope"
                  content="Message"
                  disabled={!mech.pilot}
                  onClick={() =>
                    act('send_message', {
                      tracker_ref: mech.tracker_ref,
                    })
                  }
                />
                <Button
                  icon="wifi"
                  content={mech.emp_recharging ? 'Recharging...' : 'EMP Burst'}
                  color="bad"
                  disabled={mech.emp_recharging}
                  onClick={() =>
                    act('shock', {
                      tracker_ref: mech.tracker_ref,
                    })
                  }
                />
              </>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Integrity">
                <Box
                  color={
                    (mech.integrity <= 30 && 'bad') ||
                    (mech.integrity <= 70 && 'average') ||
                    'good'
                  }
                >
                  {mech.integrity}%
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Charge">
                <Box
                  color={
                    (mech.charge <= 30 && 'bad') ||
                    (mech.charge <= 70 && 'average') ||
                    'good'
                  }
                >
                  {(typeof mech.charge === 'number' && `${mech.charge}%`) ||
                    'Not Found'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Airtank">
                {(typeof mech.airtank === 'number' && (
                  <AnimatedNumber
                    value={mech.airtank}
                    format={(value) => `${toFixed(value, 2)} kPa`}
                  />
                )) ||
                  'Not Equipped'}
              </LabeledList.Item>
              <LabeledList.Item label="Pilot">
                {(mech.pilot.length > 0 &&
                  mech.pilot.map((pilot) => (
                    <Box key={pilot} inline>
                      {pilot}
                      {mech.pilot.length > 1 ? '|' : ''}
                    </Box>
                  ))) ||
                  'None'}
              </LabeledList.Item>
              <LabeledList.Item label="Location">
                {mech.location || 'Unknown'}
              </LabeledList.Item>
              {mech.cargo_space >= 0 && (
                <LabeledList.Item label="Used Cargo Space">
                  <Box
                    color={
                      (mech.cargo_space <= 30 && 'good') ||
                      (mech.cargo_space <= 70 && 'average') ||
                      'bad'
                    }
                  >
                    {mech.cargo_space}%
                  </Box>
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};

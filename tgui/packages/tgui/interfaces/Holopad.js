import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const Holopad = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    calling,
    allowed,
  } = data;
  return (
    <Window>
      <Window.Content>
        {calling && (
          <Fragment>
            <Box
              bold
              fontSize="36px"
              mt={5}
              mb={2}
              textAlign="center"
              fontFamily="monospace">
              Dialing...
            </Box>
            <Box
              textAlign="center"
              fontSize="24px">
              <Button
                lineHeight="40px"
                icon="times"
                content="Hang Up"
                color="bad"
                onClick={() => act('hang_up')} />
            </Box>
          </Fragment>
        ) || (
          <HolopadContent />
        )}
      </Window.Content>
    </Window>
  );
};

const HolopadContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on_network,
    on_cooldown,
    allowed,
    disk,
    disk_record,
    replay_mode,
    loop_mode,
    record_mode,
    holo_calls = [],
  } = data;
  return (
    <Fragment>
      <Section
        title="Holopad"
        buttons={(
          <Button
            icon="bell"
            content={on_cooldown ? "AI Requested" : "Request AI"}
            disabled={!on_network || on_cooldown}
            onClick={() => act('AIrequest')} />
        )} >
        <LabeledList>
          <LabeledList.Item label="Controls">
            <Button
              icon="phone-alt"
              content={allowed ? "Connect to holopad" : "Call holopad"}
              disabled={!on_network}
              onClick={() => act('holocall', { headcall: allowed })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Holodisk"
        buttons={
          <Button
            icon="eject"
            content="Eject"
            disabled={!disk || replay_mode}
            onClick={() => act('disk_eject')} />
        }>
        {!disk && (
          <NoticeBox>
            No holodisk
          </NoticeBox>
        ) || (
          <LabeledList>
            <LabeledList.Item label="Disk">
              <Button
                icon={replay_mode ? 'times' : 'play'}
                content={replay_mode ? 'Stop Replaying' : 'Replay'}
                selected={replay_mode}
                onClick={() => act(replay_mode
                  ? 'replay_stop'
                  : 'replay_start')} />
              <Button
                icon={'sync'}
                content={loop_mode ? 'Looping' : 'Loop'}
                selected={loop_mode}
                onClick={() => act(loop_mode ? 'loop_stop' : 'loop_start')} />
              <Button
                icon="eject"
                content="Change Offset"
                disabled={!replay_mode}
                onClick={() => act('offset')} />
            </LabeledList.Item>
            <LabeledList.Item label="Recorder">
              <Button
                icon={record_mode ? 'times' : 'video'}
                content={record_mode ? 'End Recording' : 'Record'}
                selected={record_mode}
                disabled={disk_record}
                onClick={() => act(record_mode
                  ? 'record_stop'
                  : 'record_start')} />
              <Button
                icon="times"
                content="Clear Recording"
                color="bad"
                disabled={!disk_record || replay_mode || record_mode}
                onClick={() => act('record_clear')} />
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </Fragment>
  );
};

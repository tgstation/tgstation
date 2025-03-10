import { Dispatch, SetStateAction } from 'react';
import { Box } from 'tgui-core/components';
import { Button } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { AirAlarmData, AlarmScreen } from '../types';

type Props = {
  setScreen?: Dispatch<SetStateAction<AlarmScreen>>;
};

export function AirAlarmControlHome(props: Props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { setScreen } = props;
  if (!setScreen) {
    throw new Error('setScreen is required');
  }

  const {
    allowLinkChange,
    atmosAlarm,
    filteringPath,
    panicSiphonPath,
    selectedModePath,
    sensor,
  } = data;

  const isPanicSiphoning = selectedModePath === panicSiphonPath;
  return (
    <>
      <Button
        icon={atmosAlarm ? 'exclamation-triangle' : 'exclamation'}
        color={atmosAlarm && 'caution'}
        onClick={() => act(atmosAlarm ? 'reset' : 'alarm')}
      >
        Area Atmosphere Alarm
      </Button>
      <Box mt={1} />
      <Button
        icon={isPanicSiphoning ? 'exclamation-triangle' : 'exclamation'}
        color={isPanicSiphoning && 'danger'}
        onClick={() =>
          act('mode', {
            mode: isPanicSiphoning ? filteringPath : panicSiphonPath,
          })
        }
      >
        Panic Siphon
      </Button>
      <Box mt={2} />
      <Button icon="sign-out-alt" onClick={() => setScreen('vents')}>
        Vent Controls
      </Button>
      <Box mt={1} />
      <Button icon="filter" onClick={() => setScreen('scrubbers')}>
        Scrubber Controls
      </Button>
      <Box mt={1} />
      <Button icon="cog" onClick={() => setScreen('modes')}>
        Operating Mode
      </Button>
      <Box mt={1} />
      <Button icon="chart-bar" onClick={() => setScreen('thresholds')}>
        Alarm Thresholds
      </Button>
      {!!sensor && !!allowLinkChange && (
        <Box mt={1}>
          <Button.Confirm
            icon="link-slash"
            color="danger"
            onClick={() => act('disconnect_sensor')}
          >
            Disconnect Sensor
          </Button.Confirm>
        </Box>
      )}
    </>
  );
}

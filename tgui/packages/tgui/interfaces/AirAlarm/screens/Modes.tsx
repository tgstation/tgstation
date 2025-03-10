import { Fragment } from 'react';
import { Box } from 'tgui-core/components';
import { Button } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { AirAlarmData } from '../types';

export function AirAlarmControlModes(props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { modes, selectedModePath } = data;

  if (!modes || modes.length === 0) {
    return <span>Nothing to show</span>;
  }

  return (
    <>
      {modes.map((mode) => (
        <Fragment key={mode.path}>
          <Button
            icon={
              mode.path === selectedModePath ? 'check-square-o' : 'square-o'
            }
            color={
              mode.path === selectedModePath && (mode.danger ? 'red' : 'green')
            }
            onClick={() => act('mode', { mode: mode.path })}
          >
            {mode.name + ' - ' + mode.desc}
          </Button>
          <Box mt={1} />
        </Fragment>
      ))}
    </>
  );
}

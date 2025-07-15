import { useBackend } from 'tgui/backend';
import { Button, NoticeBox, Stack } from 'tgui-core/components';

import type { AirAlarmData } from '../types';

export function AirAlarmControlModes(props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { modes, selectedModePath } = data;

  if (!modes || modes.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        Nothing to show
      </NoticeBox>
    );
  }

  return (
    <Stack vertical>
      {modes.map((mode) => (
        <Stack.Item key={mode.path}>
          <Button
            icon={
              mode.path === selectedModePath ? 'check-square-o' : 'square-o'
            }
            color={
              mode.path === selectedModePath && (mode.danger ? 'red' : 'green')
            }
            onClick={() => act('mode', { mode: mode.path })}
          >
            {`${mode.name} - ${mode.desc}`}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}

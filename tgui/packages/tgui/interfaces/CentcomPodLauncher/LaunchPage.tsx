import { multiline } from 'common/string';

import { useBackend } from '../../backend';
import { Box, Button } from '../../components';
import { PodLauncherData } from './types';
import { useCompact } from './useCompact';

export function LaunchPage(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { giveLauncher } = data;

  const { compact } = useCompact();

  return (
    <Button
      fluid
      textAlign="center"
      tooltip={multiline`
        You should know what the
        Codex Astartes says about this`}
      selected={giveLauncher}
      tooltipPosition="top"
      onClick={() => act('giveLauncher')}
    >
      <Box bold fontSize="1.4em" lineHeight={compact ? 1.5 : 3}>
        LAUNCH
      </Box>
    </Button>
  );
}

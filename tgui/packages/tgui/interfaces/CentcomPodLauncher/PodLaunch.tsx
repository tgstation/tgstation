import { useBackend } from '../../backend';
import { Box, Button } from '../../components';
import { useCompact } from './hooks';
import { PodLauncherData } from './types';

export function PodLaunch(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { giveLauncher } = data;

  const [compact] = useCompact();

  return (
    <Button
      fluid
      onClick={() => act('giveLauncher')}
      selected={giveLauncher}
      textAlign="center"
      tooltip={`
        You should know what the
        Codex Astartes says about this`}
      tooltipPosition="top"
    >
      <Box bold fontSize="1.4em" lineHeight={compact ? 1.5 : 3}>
        LAUNCH
      </Box>
    </Button>
  );
}

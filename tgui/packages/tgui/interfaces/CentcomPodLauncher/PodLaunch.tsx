import { multiline } from 'common/string';
import { useAtom } from 'jotai';

import { useBackend } from '../../backend';
import { Box, Button } from '../../components';
import { compactAtom } from './hooks';
import { PodLauncherData } from './types';

export function PodLaunch(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { giveLauncher } = data;

  const [compact] = useAtom(compactAtom);

  return (
    <Button
      fluid
      onClick={() => act('giveLauncher')}
      selected={giveLauncher}
      textAlign="center"
      tooltip={multiline`
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

import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { PodLauncherData } from './types';

export function TabPod(props) {
  return (
    <Box color="label">
      Note: You can right click on this
      <br />
      blueprint pod and edit vars directly
    </Box>
  );
}

export function TabBay(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { oldArea } = data;

  return (
    <>
      <Button icon="street-view" onClick={() => act('teleportCentcom')}>
        Teleport
      </Button>
      <Button
        disabled={!oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')}
      >
        {oldArea ? oldArea.substring(0, 17) : 'Go Back'}
      </Button>
    </>
  );
}

export function TabDrop(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { oldArea } = data;

  return (
    <>
      <Button icon="street-view" onClick={() => act('teleportDropoff')}>
        Teleport
      </Button>
      <Button
        disabled={!oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')}
      >
        {oldArea ? oldArea.substring(0, 17) : 'Go Back'}
      </Button>
    </>
  );
}

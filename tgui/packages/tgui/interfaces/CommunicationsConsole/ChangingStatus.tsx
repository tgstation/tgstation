import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  StatusDisplayControls,
  type StatusDisplayControlsData,
} from '../common/StatusDisplayControls';
import { ShuttleState } from './types';

export function PageChangingStatus(props) {
  const { act, data } = useBackend<StatusDisplayControlsData>();

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          onClick={() => act('setState', { state: ShuttleState.MAIN })}
        >
          Back
        </Button>
      </Section>

      <StatusDisplayControls act={act} data={data} />
    </Box>
  );
}

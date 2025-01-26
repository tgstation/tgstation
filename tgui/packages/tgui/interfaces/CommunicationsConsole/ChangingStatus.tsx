import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { StatusDisplayControls } from '../common/StatusDisplayControls';
import { ShuttleState } from './types';

export function PageChangingStatus(props) {
  const { act } = useBackend();

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

      <StatusDisplayControls />
    </Box>
  );
}

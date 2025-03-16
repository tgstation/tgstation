// import { useState } from 'react';
// import { Box, Button, Checkbox, Flex, Section, Text } from 'tgui/components';
import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export type DoorRemoteRecordsData = {
  Actions: Record<number, string[]>;
  Blocked: Record<string, string>;
  Denied: Record<string, string>;
};

function DisplayActions(actionSet: Record<number, string[]>) {
  return;
}

export function DoorRemoteRecords(props) {
  const { act, data } = useBackend<DoorRemoteRecordsData>();
  const { Actions, Blocked, Denied } = data;
  const actionSet = DisplayActions(Actions);

  return (
    <Window title="Door Remote Records">
      <Window.Content>
        <Box>
          <Section>
            <Button onClick={() => act('update')}>Refresh Records</Button>
          </Section>
          <Section title="Actions" />
          <Section title="Blocked">Blocked</Section>
          <Section title="Denied">Denied</Section>
        </Box>
      </Window.Content>
    </Window>
  );
}

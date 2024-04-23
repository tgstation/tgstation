import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { CRIMESTATUS2COLOR } from './common/StatusToIcon';

type Data = {
  available_points: number;
  total_points: number;
} & Partial<{
  occupant: string;
  processing: BooleanLike;
  teleporter_lock: BooleanLike;
  teleporter_open: BooleanLike;
  wanted_status: string;
}>;

export function GulagTeleporterConsole(props) {
  const { act, data } = useBackend<Data>();
  const { teleporter_lock, teleporter_open, processing, occupant } = data;

  let canTeleport =
    !processing && !!teleporter_lock && !teleporter_open && occupant;

  return (
    <Window width={350} height={270} title="Labor Camp Teleporter">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              buttons={
                <>
                  <Button
                    selected={!!teleporter_open}
                    icon={teleporter_open ? 'door-open' : 'door-closed'}
                    onClick={() => act('toggle_open')}
                  >
                    Open
                  </Button>
                  <Button
                    selected={!!teleporter_lock}
                    icon={teleporter_lock ? 'lock' : 'lock-open'}
                    onClick={() => act('toggle_lock')}
                  >
                    Lock
                  </Button>
                </>
              }
              fill
              title="Teleporter Console"
            >
              {!occupant ? (
                <NoticeBox>No occupant detected.</NoticeBox>
              ) : (
                <OccupantDisplay />
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <SecurityStats />
          </Stack.Item>
          <Stack.Item>
            <Button
              color="bad"
              disabled={!canTeleport}
              fluid
              onClick={() => act('teleport')}
              textAlign="center"
              tooltip={
                !canTeleport &&
                'Teleporter must be locked with a valid occupant.'
              }
            >
              Process Prisoner
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function OccupantDisplay(props) {
  const { data } = useBackend<Data>();
  const { occupant = 'Unknown', wanted_status } = data;

  const status = (wanted_status && ` (${wanted_status})`) || '';

  return (
    <>
      <Box color="label">Occupant:</Box>
      <Box fontSize="17px">{occupant}</Box>
      <Box color={CRIMESTATUS2COLOR[status]}>{status}</Box>
    </>
  );
}

function SecurityStats(props) {
  const { data } = useBackend<Data>();
  const { available_points, total_points } = data;

  return (
    <Section title="Security Stats">
      <LabeledList>
        <LabeledList.Item label="Available Points">
          {available_points}
        </LabeledList.Item>
        <LabeledList.Item label="Total Points">{total_points}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

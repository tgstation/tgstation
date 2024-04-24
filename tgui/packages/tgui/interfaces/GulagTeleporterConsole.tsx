import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { CRIMESTATUS2COLOR } from './common/StatusToIcon';

type Data = {
  available_points: number;
  last_bounty: number;
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
  const { occupant, processing, teleporter_lock, teleporter_open } = data;

  let canTeleport =
    !processing && !!teleporter_lock && !teleporter_open && occupant;

  return (
    <Window width={350} height={275} title="Labor Camp Teleporter">
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
              selected={!!processing}
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
  const { occupant = 'Unknown', wanted_status = '' } = data;

  const status = (wanted_status && ` (${wanted_status})`) || '';

  return (
    <>
      <Box color="label">Occupant:</Box>
      <Box fontSize="17px">{occupant}</Box>
      <Box bold color={CRIMESTATUS2COLOR[wanted_status]}>
        {status}
      </Box>
    </>
  );
}

function SecurityStats(props) {
  const { data } = useBackend<Data>();
  const { available_points, last_bounty, total_points } = data;

  let lastBounty = 'None';
  let color = '';
  if (last_bounty > 0) {
    lastBounty = `+${last_bounty} cr`;
    color = 'good';
  } else if (last_bounty < 0) {
    lastBounty = `${last_bounty} cr`;
    color = 'bad';
  }

  return (
    <Section title="Security Stats">
      <LabeledList>
        <LabeledList.Item label="Department Funds">
          {available_points} cr <Icon name="coins" color="gold" />
        </LabeledList.Item>
        <LabeledList.Item color={color} label="Last Bounty">
          {lastBounty}
        </LabeledList.Item>
        <LabeledList.Item label="Bounties Awarded">
          {total_points} cr
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

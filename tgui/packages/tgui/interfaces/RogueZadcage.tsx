import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  bonded: BooleanLike;
  severed: BooleanLike;
  slot_label: string;
  cote_name: string;
  cote_motto: string;
  allow_summons: BooleanLike;
  pending_flight: BooleanLike;
  occupied: BooleanLike;
  time_remaining: number;
  warning: BooleanLike;
  capacity: number;
  reply_message: string;
  held: { name: string; w_class: number } | null;
  stored: string[];
};

/** Zadcage: a carrier zad's perch on the belt (Ratwood Zadcage.tsx). */
export const RogueZadcage = () => {
  const { act, data } = useBackend<Data>();
  const [sendHeld, setSendHeld] = useState(false);
  const [zads, setZads] = useState(1);
  return (
    <Window width={400} height={360}>
      <Window.Content>
        <Section title={data.bonded ? `${data.cote_name} - ${data.slot_label}` : 'Unbonded zadcage'}>
          {!!data.severed && <NoticeBox>The zadlink has been severed.</NoticeBox>}
          {data.stored.length > 0 && (
            <Box mb={1}>
              Parcels: {data.stored.join(', ')}{' '}
              <Button icon="hand-holding" onClick={() => act('retrieve')}>
                Take
              </Button>
            </Box>
          )}
          {data.occupied ? (
            <>
              <Box color={data.warning ? 'bad' : undefined}>
                A zad waits ({data.capacity} zad(s)) for {data.time_remaining}{' '}
                more seconds.
              </Box>
              <Input
                mt={1}
                fluid
                placeholder="Reply..."
                value={data.reply_message}
                onBlur={(value) => act('set_reply', { message: value })}
              />
              <Button.Checkbox
                mt={1}
                checked={sendHeld}
                disabled={!data.held}
                onClick={() => setSendHeld(!sendHeld)}
              >
                Give it what I hold{data.held ? `: ${data.held.name}` : ''}
              </Button.Checkbox>
              <Button
                mt={1}
                icon="dove"
                onClick={() => act('send_reply', { send_held: sendHeld })}
              >
                Send it home
              </Button>
            </>
          ) : (
            !!data.bonded &&
            !data.severed &&
            !!data.allow_summons && (
              <Box>
                Call{' '}
                <NumberInput
                  value={zads}
                  minValue={1}
                  maxValue={3}
                  step={1}
                  width="40px"
                  onChange={setZads}
                />{' '}
                zad(s) from the cote{' '}
                <Button
                  disabled={!!data.pending_flight}
                  onClick={() => act('summon', { zads })}
                >
                  Summon
                </Button>
              </Box>
            )
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Slot = {
  slot: number;
  name: string;
  label: string;
  severed: BooleanLike;
  bonded: BooleanLike;
  occupied: BooleanLike;
  has_payload: BooleanLike;
  allow_summons: BooleanLike;
  in_flight: BooleanLike;
  flight_zads: number | null;
  flight_seconds: number;
  flight_bombs: number | null;
};

type LogEntry = {
  stamp: string;
  slot: number;
  sender: string;
  message: string;
  items: string[];
  kind: string;
  zads_used: number;
  bombs: number;
  lost: number;
  summoned: BooleanLike;
};

type Data = {
  motto: string;
  reserve: number;
  reserve_cap: number;
  flights: number;
  flight_cap: number;
  bomb_stock: number;
  bomb_cooldown: number;
  allows_voyeur: BooleanLike;
  voyeur_fund: number;
  voyeur_cost: number;
  mail_log: LogEntry[];
  held: { name: string; w_class: number } | null;
  slots: Slot[];
};

const slotState = (slot: Slot) => {
  if (slot.severed) return 'severed';
  if (!slot.bonded) return 'no cage';
  if (slot.in_flight)
    return `${slot.flight_zads} zad(s) in flight, ${slot.flight_seconds}s`;
  if (slot.occupied) return 'zad waiting at the cage';
  if (slot.has_payload) return 'parcels unclaimed';
  return 'ready';
};

/** ZADCOTE: the bird mail of the merchant, the stewardry and the bathhouse (Ratwood Zadcote.tsx). */
export const RogueZadcote = () => {
  const { act, data } = useBackend<Data>();
  const [picked, setPicked] = useState(1);
  const [zads, setZads] = useState(1);
  const [bombs, setBombs] = useState(0);
  const [message, setMessage] = useState('');
  const [caw, setCaw] = useState('');
  const [sendHeld, setSendHeld] = useState(false);
  const slot = data.slots.find((entry) => entry.slot === picked);
  return (
    <Window width={720} height={640}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title={data.motto}
              buttons={
                !!data.allows_voyeur && (
                  <Button
                    icon="coins"
                    disabled={data.voyeur_fund <= 0}
                    onClick={() => act('withdraw_voyeur')}
                  >
                    Drain basin ({data.voyeur_fund}m)
                  </Button>
                )
              }
            >
              Reserve: {data.reserve}/{data.reserve_cap} zads. Flights:{' '}
              {data.flights}/{data.flight_cap}. Bombs: {data.bomb_stock}
              {data.bomb_cooldown > 0 &&
                ` (next bomb flight in ${data.bomb_cooldown}s)`}
              .
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="230px">
                <Section fill scrollable title="Zadlinks">
                  <Tabs vertical>
                    {data.slots.map((entry) => (
                      <Tabs.Tab
                        key={entry.slot}
                        selected={entry.slot === picked}
                        onClick={() => setPicked(entry.slot)}
                      >
                        {entry.label}
                        <Box color="label" fontSize="0.85em">
                          {slotState(entry)}
                        </Box>
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                {slot ? (
                  <Section fill scrollable title={`Slot ${slot.slot}`}>
                    <LabeledList>
                      <LabeledList.Item label="Name">
                        <Input
                          value={slot.name}
                          placeholder={`Slot ${slot.slot}`}
                          onBlur={(value) =>
                            act('set_slot_name', { slot: slot.slot, name: value })
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="State">
                        {slotState(slot)}
                      </LabeledList.Item>
                      <LabeledList.Item label="Zads">
                        <NumberInput
                          value={zads}
                          minValue={1}
                          maxValue={3}
                          step={1}
                          width="40px"
                          onChange={setZads}
                        />{' '}
                        (1: small, 2: a pouch, 3: something bulky)
                      </LabeledList.Item>
                      <LabeledList.Item label="Bombs">
                        <NumberInput
                          value={bombs}
                          minValue={0}
                          maxValue={3}
                          step={1}
                          width="40px"
                          onChange={setBombs}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                    {bombs > 0 ? (
                      <Input
                        mt={1}
                        fluid
                        placeholder="What the zads caw as they drop them..."
                        value={caw}
                        onChange={setCaw}
                      />
                    ) : (
                      <>
                        <Input
                          mt={1}
                          fluid
                          placeholder="Message..."
                          value={message}
                          onChange={setMessage}
                        />
                        <Button.Checkbox
                          mt={1}
                          checked={sendHeld}
                          disabled={!data.held}
                          onClick={() => setSendHeld(!sendHeld)}
                        >
                          Send what I hold
                          {data.held ? `: ${data.held.name}` : ''}
                        </Button.Checkbox>
                      </>
                    )}
                    <Box mt={1}>
                      <Button
                        icon="dove"
                        disabled={
                          !!slot.severed || !slot.bonded || !!slot.in_flight
                        }
                        onClick={() =>
                          act('dispatch', {
                            slot: slot.slot,
                            zads,
                            bombs,
                            message,
                            bomb_caw: caw,
                            send_held: sendHeld && !bombs,
                          })
                        }
                      >
                        Dispatch
                      </Button>
                      <Button.Checkbox
                        checked={!!slot.allow_summons}
                        onClick={() =>
                          act('toggle_summons', { slot: slot.slot })
                        }
                      >
                        Allow summons
                      </Button.Checkbox>
                      {!!data.allows_voyeur && (
                        <Button
                          icon="eye"
                          disabled={!slot.bonded || !!slot.severed}
                          onClick={() => act('voyeur', { slot: slot.slot })}
                        >
                          Scry ({data.voyeur_cost}m)
                        </Button>
                      )}
                      <Button
                        color="bad"
                        disabled={!!slot.severed || !slot.bonded}
                        onClick={() => act('sever', { slot: slot.slot })}
                      >
                        Sever
                      </Button>
                    </Box>
                  </Section>
                ) : (
                  <NoticeBox>Pick a zadlink.</NoticeBox>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item height="150px">
            <Section fill scrollable title="Mail log">
              {data.mail_log.map((entry, index) => (
                <Box key={index}>
                  [{entry.stamp}] {entry.kind === 'sent' ? 'Sent to' : 'From'}{' '}
                  {entry.sender}: {entry.zads_used} zad(s)
                  {entry.bombs ? `, ${entry.bombs} bomb(s)` : ''}
                  {entry.summoned ? ', summoned' : ''}
                  {entry.lost ? `, ${entry.lost} lost` : ''}
                  {entry.message ? ` - "${entry.message}"` : ''}
                  {entry.items.length ? ` - ${entry.items.join(', ')}` : ''}
                </Box>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

import {
  Box,
  Button,
  Collapsible,
  Divider,
  Dropdown,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  using_instrument: string;
  note_shift_min: number;
  note_shift_max: number;
  note_shift: number;
  octaves: number;
  sustain_modes: string[];
  sustain_mode: string;
  sustain_mode_button: string;
  sustain_mode_duration: number;
  instrument_ready: BooleanLike;
  volume: number;
  volume_dropoff_threshold: number;
  min_volume: number;
  max_volume: number;
  sustain_indefinitely: BooleanLike;
  sustain_mode_min: number;
  sustain_mode_max: number;
  playing: BooleanLike;
  max_repeats: number;
  repeat: number;
  bpm: number;
  lines: LineData[];
  can_switch_instrument: BooleanLike;
  possible_instruments: InstrumentData[];
  max_line_chars: number;
  max_lines: number;
};

type InstrumentData = {
  name: string;
  id: string;
};

type LineData = {
  line_count: number;
  line_text: string;
};

export const InstrumentEditor = (props) => {
  const { data } = useBackend<Data>();

  return (
    <Window width={750} height={500}>
      <Window.Content scrollable>
        <InstrumentSettings />
        <Collapsible open title="Music Editor" icon="pencil">
          <EditingSettings />
        </Collapsible>
        <Collapsible title="Help Section" icon="question">
          <HelpSection />
        </Collapsible>
      </Window.Content>
    </Window>
  );
};

const InstrumentSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    playing,
    repeat,
    max_repeats,
    can_switch_instrument,
    possible_instruments = [],
    instrument_ready,
    using_instrument,
    note_shift_min,
    note_shift_max,
    note_shift,
    octaves,
    sustain_modes,
    sustain_mode,
    sustain_mode_button,
    sustain_mode_duration,
    sustain_indefinitely,
    sustain_mode_min,
    sustain_mode_max,
    volume,
    min_volume,
    max_volume,
    volume_dropoff_threshold,
    lines,
  } = data;

  const instrument_id_by_name = (name) => {
    return possible_instruments.find((instrument) => instrument.name === name)
      ?.id;
  };

  return (
    <Section title="Settings">
      {lines.length > 0 && (
        <Box fontSize="16px">
          <Button onClick={() => act('play_music')}>
            {playing ? 'Stop Music' : 'Start Playing'}
          </Button>
        </Box>
      )}
      <Box>
        Repeats Left:
        <NumberInput
          step={1}
          minValue={0}
          disabled={!!playing}
          maxValue={max_repeats}
          value={repeat}
          onChange={(value) =>
            act('set_repeat_amount', {
              amount: value,
            })
          }
        />
      </Box>
      <Box>
        {!!can_switch_instrument && (
          <Stack fill>
            <Stack.Item mt={0.5}>Instrument Using</Stack.Item>
            <Stack.Item grow>
              <Dropdown
                width="40%"
                selected={using_instrument}
                disabled={!can_switch_instrument}
                options={possible_instruments.map(
                  (instrument) => instrument.name,
                )}
                onSelected={(value) =>
                  act('change_instrument', {
                    new_instrument: instrument_id_by_name(value),
                  })
                }
              />
            </Stack.Item>
          </Stack>
        )}
      </Box>
      <Stack mt={1}>
        <Stack.Item>
          Playback Settings:
          <Box>
            <NumberInput
              minValue={note_shift_min}
              maxValue={note_shift_max}
              step={1}
              value={note_shift}
              onChange={(value) =>
                act('set_note_shift', {
                  amount: value,
                })
              }
            />
            keys / {octaves} octaves
          </Box>
          <Stack>
            <Stack.Item mt={0.5}>Mode:</Stack.Item>
            <Stack.Item grow>
              <Dropdown
                width="100%"
                selected={sustain_mode}
                options={sustain_modes}
                onSelected={(value) =>
                  act('set_sustain_mode', {
                    new_mode: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
          <Box>
            {sustain_mode_button}:
            <NumberInput
              step={1}
              minValue={sustain_mode_min}
              maxValue={sustain_mode_max}
              value={sustain_mode_duration}
              onChange={(value) =>
                act('edit_sustain_mode', {
                  amount: value,
                })
              }
            />
          </Box>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item>
          <Box>
            Status:
            {instrument_ready ? (
              <span style={{ color: '#5EFB6E' }}> Ready</span>
            ) : (
              <span style={{ color: '#FF0000' }}>
                {' '}
                Instrument Definition Error!
              </span>
            )}
          </Box>
          <Box>
            Volume:
            <NumberInput
              step={1}
              minValue={min_volume}
              maxValue={max_volume}
              value={volume}
              onChange={(value) =>
                act('set_volume', {
                  amount: value,
                })
              }
            />
          </Box>
          <Box>
            Volume Dropoff Threshold:
            <NumberInput
              step={1}
              minValue={1}
              maxValue={100}
              value={volume_dropoff_threshold}
              onChange={(value) =>
                act('set_dropoff_volume', {
                  amount: value,
                })
              }
            />
          </Box>
          <Box>
            <Button onClick={() => act('toggle_sustain_hold_indefinitely')}>
              {sustain_indefinitely
                ? 'Sustaining last held note indefinitely'
                : 'Not sustaining last held note indefinitely'}
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EditingSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const { bpm, lines } = data;

  return (
    <Section>
      <Box>
        <Button onClick={() => act('start_new_song')}>Start a New Song</Button>
        <Button onClick={() => act('import_song')}>Import a Song</Button>
      </Box>
      <Box>
        Tempo:{' '}
        <Button
          onClick={() => act('tempo', { tempo_change: 'increase_speed' })}
        >
          -
        </Button>{' '}
        {bpm} BPM{' '}
        <Button
          onClick={() => act('tempo', { tempo_change: 'decrease_speed' })}
        >
          +
        </Button>
      </Box>
      <Box>
        {lines.map((line, index) => (
          <Box key={index} fontSize="11px">
            Line {index}:
            <Button
              onClick={() =>
                act('modify_line', { line_editing: line.line_count })
              }
            >
              Edit
            </Button>
            <Button
              onClick={() =>
                act('delete_line', { line_deleted: line.line_count })
              }
            >
              X
            </Button>
            {line.line_text}
          </Box>
        ))}
      </Box>
      <Box>
        <Button onClick={() => act('add_new_line')}>Add Line</Button>
      </Box>
    </Section>
  );
};

const HelpSection = (props) => {
  const { data } = useBackend<Data>();
  const { max_line_chars, max_lines } = data;

  return (
    <Section>
      <Box>
        Lines are a series of chords, separated by commas (,), each with notes
        separated by hyphens (-).
        <br />
        Every note in a chord will play together, with chord timed by the tempo.
        <br />
        Notes are played by the names of the note, and optionally, the
        accidental, and/or the octave number.
        <br />
        By default, every note is natural and in octave 3. Defining otherwise is
        remembered for each note.
        <br />
        Example: <i>C,D,E,F,G,A,B</i> will play a C major scale.
        <br />
        After a note has an accidental placed, it will be remembered:{' '}
        <i>C,C4,C,C3</i> is <i>C3,C4,C4,C3</i>
        <br />
        Chords can be played simply by seperating each note with a hyphon:{' '}
        <i>A-C#,Cn-E,E-G#,Gn-B</i>
        <br />A pause may be denoted by an empty chord: <i>C,E,,C,G</i>
        <br />
        To make a chord be a different time, end it with /x, where the chord
        length will be length
        <br />
        defined by tempo / x: <i>C,G/2,E/4</i>
        <br />
        Combined, an example is: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i>
        <br />
        Lines may be up to {max_line_chars} characters.
        <br />A song may only contain up to {max_lines} lines.
        <br />
      </Box>
    </Section>
  );
};

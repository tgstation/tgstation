import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  using_instrument: string;
  note_shift: number;
  octaves: number;
  sustain_mode: string;
  sustain_mode_button: string;
  sustain_mode_text: string;
  instrument_ready: BooleanLike;
  volume: number;
  volume_dropoff_threshold: number;
  sustain_indefinitely: BooleanLike;
  playing: BooleanLike;
  max_repeats: number;
  repeat: number;
  bpm: number;
  lines: LineData[];
  can_switch_instrument: BooleanLike;
  max_line_chars: number;
  max_lines: number;
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

export const InstrumentSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    playing,
    repeat,
    max_repeats,
    can_switch_instrument,
    instrument_ready,
    using_instrument,
    note_shift,
    octaves,
    sustain_mode,
    sustain_mode_button,
    sustain_mode_text,
    sustain_indefinitely,
    volume,
    volume_dropoff_threshold,
    lines,
  } = data;

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
        <Button disabled={playing} onClick={() => act('set_repeat')}>
          Repeats Left
        </Button>
        : {repeat} / {max_repeats}
      </Box>
      <Box>
        <Button
          disabled={!can_switch_instrument}
          onClick={() => act('switch_instrument')}
        >
          Current Instrument
        </Button>
        : {using_instrument}
      </Box>
      <Stack>
        <Stack.Item>
          Playback Settings:
          <Box>
            <Button onClick={() => act('set_note_shift')}>
              Note Shift/Note Transpose
            </Button>
            : {note_shift} keys / {octaves} octaves
          </Box>
          <Box>
            <Button onClick={() => act('set_sustain_mode')}>
              Sustain Mode
            </Button>
            : {sustain_mode}
          </Box>
          <Box>
            <Button onClick={() => act('edit_sustain_mode')}>
              {sustain_mode_button}
            </Button>
            : {sustain_mode_text}
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
            <Button onClick={() => act('set_volume')}>Volume</Button>: {volume}
          </Box>
          <Box>
            <Button onClick={() => act('set_dropoff_volume')}>
              Volume Dropoff Threshold
            </Button>
            : {volume_dropoff_threshold}
          </Box>
          <Box>
            <Button onClick={() => act('toggle_sustain_hold_indefinitely')}>
              Sustain indefinitely last held note
            </Button>
            : {sustain_indefinitely ? 'Enabled' : 'Disabled'}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const EditingSettings = (props) => {
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

export const HelpSection = (props) => {
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

import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Collapsible, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  using_instrument: string;
  note_shift: number;
  octaves: number;
  sustain_mode: string;
  sustain_mode_text: string;
  instrument_ready: BooleanLike;
  legacy_mode: BooleanLike;
  volume: number;
  volume_dropoff_threshold: number;
  sustain_indefinitely: BooleanLike;
  has_lines: BooleanLike;
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
    <Window width={600} height={400}>
      <Window.Content>
        <InstrumentSettings />
        <Collapsible title="Music Editor" icon="pencil">
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
  const { data } = useBackend<Data>();

  return <Section>Instrument Settings</Section>;
};

export const EditingSettings = (props) => {
  const { data } = useBackend<Data>();

  return <Section>Editing Settings</Section>;
};

export const HelpSection = (props) => {
  const { data } = useBackend<Data>();

  return <Section>Help Section</Section>;
};

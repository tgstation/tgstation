import { useBackend } from '../backend';
import {
  Button,
  Section,
  Knob,
  LabeledControls,
  NoticeBox,
} from '../components';
import { Window } from '../layouts';

type SimpleBotContext = {
  maintenance_open: number;
  locked: number;
  pai?: Pai;
  controls: Controls;
};

type Pai = {
  card_inserted: number;
  allow_pai: number;
};

type Controls = {
  [Control: string]: [Value: number];
};

export const SimpleBot = (_, context) => {
  return (
    <Window width={600} height={250}>
      <Window.Content>
        <ControlsDisplay />
      </Window.Content>
    </Window>
  );
};

const StatusDisplay = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);
  const { locked, maintenance_open } = data;

  return (
    <>
      <Button.Checkbox
        checked={locked}
        icon={locked ? 'lock' : 'lock-open'}
        onClick={() => act('toggle_lock')}>
        Controls Lock
      </Button.Checkbox>
      <Button.Checkbox
        checked={!maintenance_open}
        icon={!maintenance_open ? 'lock' : 'lock-open'}
        onClick={() => act('toggle_maintenance')}>
        Maintenance Panel
      </Button.Checkbox>
    </>
  );
};

const ControlsDisplay = (_, context) => {
  const { data } = useBackend<SimpleBotContext>(context);
  const { controls } = data;

  return (
    <Section title="Controls" buttons={<StatusDisplay />}>
      <LabeledControls>
        {Object.entries(controls).map((control) => {
          return (
            <LabeledControls.Item
              key={control[0]}
              label={control[0]
                .replace(/^\w/, (c) => c.toUpperCase())
                .replace('_', ' ')}>
              <ControlHelper control={control} />
            </LabeledControls.Item>
          );
        })}
      </LabeledControls>
      {controls.pai && <PaiDisplay />}
    </Section>
  );
};

const ControlHelper = (props, context) => {
  const { act } = useBackend<SimpleBotContext>(context);
  const { control } = props;

  if (control[0] === 'sync_tech') {
    /** Control is for sync - this is medbot specific */
    return (
      <Button
        tooltip="Synchronize surgical data with research network. Improves Efficiency."
        onClick={() => act('sync_tech')}>
        Update
      </Button>
    );
  } else if (control[1] === 0 || control[1] === 1) {
    /** Control is an on/off toggle */
    return (
      <Button selected={control[1]} onClick={() => act(control[0])}>
        {control[1] ? 'ON' : 'OFF'}
      </Button>
    );
  } else if (control[1] > 1) {
    /** Control is a threshold - this is medbot specific */
    return (
      <Knob
        minValue={5}
        maxValue={75}
        step={5}
        value={control[1]}
        onChange={(_, value) => act(control[0], { value })}
      />
    );
  } else {
    return 'Error!';
  }
};

const PaiDisplay = (props, context) => {
  const { act } = useBackend<SimpleBotContext>(context);

  return (
    <Section fill title="PAI Information">
      <NoticeBox>No PAI Loaded!</NoticeBox>
    </Section>
  );
};

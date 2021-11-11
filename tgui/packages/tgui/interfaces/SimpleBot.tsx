import { useBackend } from '../backend';
import {
  Button,
  Knob,
  LabeledControls,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type SimpleBotContext = {
  maintenance_open: number;
  locked: number;
  emagged: number;
  pai?: Pai;
  settings: Settings;
  custom_controls: Controls;
};

type Pai = {
  card_inserted: number;
  allow_pai: number;
};

type Settings = {
  power: number;
  remote_enabled: number;
  auto_patrol?: number;
};

type Controls = {
  [Control: string]: [Value: number];
};

export const SimpleBot = (_, context) => {
  const { data } = useBackend<SimpleBotContext>(context);
  const { locked } = data;

  return (
    <Window width={600} height={250}>
      <Window.Content>
        <Section fill title="Controls" buttons={<StatusDisplay />}>
          {locked ? (
            <NoticeBox>Locked!</NoticeBox>
          ) : (
            <Stack fill vertical>
              <Stack.Item>
                <ControlsDisplay />
              </Stack.Item>
              <Stack.Item>
                <PaiDisplay />
              </Stack.Item>
            </Stack>
          )}
        </Section>
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
        onClick={() => act('lock')}>
        Controls Lock
      </Button.Checkbox>
      <Button.Checkbox
        checked={!maintenance_open}
        icon={!maintenance_open ? 'lock' : 'lock-open'}
        onClick={() => act('maintenance')}>
        Maintenance Panel
      </Button.Checkbox>
    </>
  );
};

const ControlsDisplay = (_, context) => {
  const { data } = useBackend<SimpleBotContext>(context);
  const { custom_controls } = data;

  return (
    <LabeledControls>
      {Object.entries(custom_controls).map((control) => {
        return (
          <LabeledControls.Item
            key={control[0]}
            label={control[0]
              .replace('_', ' ')
              .replace(/^\w/, (c) => c.toUpperCase())}>
            <ControlHelper control={control} />
          </LabeledControls.Item>
        );
      })}
    </LabeledControls>
  );
};

/** Gets standardized controls, or returns customs */
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
    return <MedbotThreshold control={control} />;
  } else {
    return 'Error!';
  }
};

const MedbotThreshold = (props, context) => {
  const { act } = useBackend<SimpleBotContext>(context);
  const { control } = props;
  return (
    <Knob
      minValue={5}
      maxValue={75}
      color={getColor(control[1])}
      step={5}
      value={control[1]}
      onDrag={(_, value) => act(control[0], { threshold: value })}
    />
  );
};

const getColor = (value: number) => {
  if (value < 15) {
    return 'good';
  } else if (value < 50) {
    return 'average';
  } else {
    return 'bad';
  }
};

const PaiDisplay = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);

  return (
    <Section fill title="PAI Information">
      <NoticeBox>No PAI Loaded!</NoticeBox>
    </Section>
  );
};

import { multiline } from '../../common/string';
import { useBackend } from '../backend';
import {
  Button,
  Icon,
  Knob,
  LabeledControls,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type SimpleBotContext = {
  locked: number;
  emagged: number;
  pai: Pai;
  settings: Settings;
  custom_controls: Controls;
};

type Pai = {
  allow_pai: number;
  card_inserted: number;
};

type Settings = {
  power: number;
  airplane_mode: number;
  maintenance_lock: number;
  patrol_station?: number;
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
        <Section fill title="Controls" buttons={<LockDisplay />}>
          {locked ? (
            <NoticeBox>Locked!</NoticeBox>
          ) : (
            <Stack fill vertical>
              <Stack.Item>
                <SettingsDisplay />
              </Stack.Item>
              <Stack.Divider />
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

/** Creates a lock button at the top of the controls */
const LockDisplay = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);
  const { locked } = data;

  return (
    <Button.Checkbox
      checked={locked}
      icon={locked ? 'lock' : 'lock-open'}
      onClick={() => act('lock')}>
      Controls Lock
    </Button.Checkbox>
  );
};

/** Displays the bot's standard settings: Power, patrol, etc. */
const SettingsDisplay = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);
  const { airplane_mode, patrol_station, power, maintenance_lock } =
    data.settings;

  return (
    <LabeledControls>
      <LabeledControls.Item label="Power">
        <Tooltip content={`Powers ${power ? 'off' : 'on'} the bot.`}>
          <Icon
            size={2}
            name="power-off"
            color={power ? 'good' : 'gray'}
            onClick={() => act('power')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Airplane Mode">
        <Tooltip
          content={`${
            !airplane_mode ? 'Disables' : 'Enables'
          } remote access via console.`}>
          <Icon
            size={2}
            name="plane"
            color={airplane_mode ? 'yellow' : 'gray'}
            onClick={() => act('airplane')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Patrol Station">
        <Tooltip
          content={`${
            patrol_station ? 'Disables' : 'Enables'
          } automatic station patrol.`}>
          <Icon
            size={2}
            name="map-signs"
            color={patrol_station ? 'good' : 'gray'}
            onClick={() => act('patrol')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Maintenance Lock">
        <Tooltip
          content={
            maintenance_lock
              ? 'Opens the maintenance hatch for repairs.'
              : 'Closes the maintenance hatch.'
          }>
          <Icon
            size={2}
            name="toolbox"
            color={maintenance_lock ? 'yellow' : 'gray'}
            onClick={() => act('maintenance')}
          />
        </Tooltip>
      </LabeledControls.Item>
    </LabeledControls>
  );
};

/** Iterates over custom controls.
 * Calls the helper to identify which button to use.
 */
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

/** Helper function which identifies which button to create.
 * Might need some fine tuning if you are using sliders rather than booleans.
 */
const ControlHelper = (props, context) => {
  const { act } = useBackend<SimpleBotContext>(context);
  const { control } = props;
  if (control[0] === 'sync_tech') {
    /** Control is for sync - this is medbot specific */
    return <MedbotSync />;
  } else if (control[1] === 0 || control[1] === 1) {
    /** Control is an on/off toggle */
    return (
      <Icon
        color={control[1] ? 'good' : 'gray'}
        name={control[1] ? 'toggle-on' : 'toggle-off'}
        size={2}
        onClick={() => act(control[0])}
      />
    );
  } else if (control[1] > 1) {
    /** Control is a threshold - this is medbot specific */
    return <MedbotThreshold control={control} />;
  } else {
    return <Icon name="bug" />;
  }
};

/** Small button to sync medbots with research. */
const MedbotSync = (_, context) => {
  const { act } = useBackend<SimpleBotContext>(context);

  return (
    <Tooltip
      content={multiline`Synchronize surgical data with research network. Improves Tending Efficiency.`}>
      <Icon
        color="purple"
        name="cloud-download-alt"
        size={2}
        onClick={() => act('sync_tech')}
      />
    </Tooltip>
  );
};

/** Knob button for medbot healing thresholds */
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

/** Color helper for medbot's threshold.
 * Ranges weren't working.
 */
const getColor = (value: number) => {
  if (value < 15) {
    return 'good';
  } else if (value < 50) {
    return 'average';
  } else {
    return 'bad';
  }
};

/** TODO: Finish this section */
const PaiDisplay = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);

  return (
    <Section fill title="PAI Information">
      <NoticeBox>No PAI Loaded!</NoticeBox>
    </Section>
  );
};

import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

type SimpleBotContext = {
  maintenance_open: number;
  locked: number;
  controls: Control[];
};

type Control = {
  [Control: string]: [Value: number];
};

export const SimpleBot = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);
  logger.log(data);

  return (
    <Window width={400} height={350}>
      <Window.Content>
        <Section title="Controls" buttons={<StatusDisplay />}>
          <ControlsDisplay />
        </Section>
      </Window.Content>
    </Window>
  );
};

const StatusDisplay = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);

  return (
    <>
      <Button.Checkbox
        checked={data.locked}
        icon={data.locked ? 'lock' : 'lock-open'}
        onClick={() => act('toggle_lock')}>
        Controls Lock
      </Button.Checkbox>
      <Button.Checkbox
        checked={!data.maintenance_open}
        icon={!data.maintenance_open ? 'lock' : 'lock-open'}
        onClick={() => act('toggle_maintenance')}>
        Maintenance Panel
      </Button.Checkbox>
    </>
  );
};

const ControlsDisplay = (_, context) => {
  const { act, data } = useBackend<SimpleBotContext>(context);
  const { controls } = data;

  return (
    <LabeledList>
      {Object.entries(controls).map((control, value) => {
        return (
          <LabeledList.Item
            key={control[0]}
            label={control[0]
              .replace(/^\w/, (c) => c.toUpperCase())
              .replace('_', ' ')}>
            {parseInt(controls[control[0]], 10) > 1
              ? control[1]
              : parseInt(controls[control[0]], 10) === 1
              ? 'On'
              : 'Off'}
          </LabeledList.Item>
        );
      })}
    </LabeledList>
  );
};

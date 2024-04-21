import { useBackend } from '../../backend';
import { Button, ProgressBar, Stack } from '../../components';
import { SubsystemData } from './types';

type Props = {
  showBars: boolean;
  max: number;
  subsystem: SubsystemData;
  value: number;
};

export function SubsystemRow(props: Props) {
  const { act } = useBackend();
  const { subsystem, value, showBars, max } = props;
  const { can_fire, doesnt_fire, initialized, name, ref } = subsystem;

  let icon = 'play';
  if (!initialized) {
    icon = 'circle-exclamation';
  } else if (doesnt_fire) {
    icon = 'check';
  } else if (!can_fire) {
    icon = 'pause';
  }

  return (
    <Stack>
      <Stack.Item grow>
        {showBars ? (
          <ProgressBar
            value={value}
            maxValue={max}
            ranges={{
              average: [75, 124.99],
              bad: [125, Infinity],
            }}
          >
            {name} {value.toFixed(0)}ms
          </ProgressBar>
        ) : (
          <Button fluid icon={icon}>
            {name}
          </Button>
        )}
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="wrench"
          tooltip="View Variables"
          onClick={() => {
            act('view_variables', { ref: ref });
          }}
        />
      </Stack.Item>
    </Stack>
  );
}

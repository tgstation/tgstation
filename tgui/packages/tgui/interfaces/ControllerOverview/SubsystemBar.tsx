import { useBackend } from '../../backend';
import { Button, ProgressBar, Stack } from '../../components';
import { SubsystemData } from './types';

type Props = {
  filterSmall: boolean;
  max: number;
  subsystem: SubsystemData;
  value: number;
};

export function SubsystemBar(props: Props) {
  const { act } = useBackend();
  const { filterSmall, max, subsystem, value } = props;
  const { ref } = subsystem;

  if (filterSmall && value < 1) return;

  return (
    <Stack>
      <Stack.Item grow>
        <ProgressBar
          value={value}
          maxValue={max}
          ranges={{
            average: [75, 124.99],
            bad: [125, Infinity],
          }}
        >
          {subsystem.name} {value.toFixed(0)}ms
        </ProgressBar>
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

import { Button, ProgressBar, Stack } from '../../components';
import { logger } from '../../logging';
import { SubsystemData } from './types';

type Props = {
  subsystem: SubsystemData;
  value: number;
  max: number;
  filterSmall: boolean;
  filterInactive: boolean;
};

export function SubsystemBar(props: Props) {
  const { subsystem, max, value, filterSmall, filterInactive } = props;

  if (filterSmall && value < 1) return;
  if (filterInactive && !subsystem.can_fire) return;

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
        <Button icon="wrench" onClick={() => logger.log('ok')} />
      </Stack.Item>
    </Stack>
  );
}

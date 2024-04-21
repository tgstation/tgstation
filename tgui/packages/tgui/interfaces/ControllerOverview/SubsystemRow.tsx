import { Dispatch } from 'react';

import { useBackend } from '../../backend';
import { Button, ProgressBar, Stack } from '../../components';
import { SortType, SubsystemData } from './types';

type Props = {
  showBars: boolean;
  max: number;
  setSelected: Dispatch<SubsystemData>;
  subsystem: SubsystemData;
  sortType: SortType;
  value: number;
};

export function SubsystemRow(props: Props) {
  const { act } = useBackend();
  const { subsystem, value, showBars, max, setSelected, sortType } = props;
  const { can_fire, doesnt_fire, initialized, name, ref } = subsystem;

  let icon = 'play';
  if (!initialized) {
    icon = 'circle-exclamation';
  } else if (doesnt_fire) {
    icon = 'check';
  } else if (!can_fire) {
    icon = 'pause';
  }

  let valueDisplay = '';
  let rangeDisplay = {};
  if (showBars) {
    if (sortType === SortType.Cost) {
      valueDisplay = value.toFixed(0) + 'ms';
      rangeDisplay = {
        average: [75, 124.99],
        bad: [125, Infinity],
      };
    } else {
      valueDisplay = (value * 0.01).toFixed(2) + '%';
      rangeDisplay = {
        average: [10, 24.99],
        bad: [25, Infinity],
      };
    }
  }

  return (
    <Stack mb={0.5}>
      <Stack.Item grow onClick={() => setSelected(subsystem)}>
        {showBars ? (
          <ProgressBar value={value} maxValue={max} ranges={rangeDisplay}>
            {name} {valueDisplay}
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

import { Knob, LabeledControls } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../../backend';
import type { PodDelay, PodLauncherData } from './types';

type Props = {
  delay_list: PodDelay[];
  reverse?: boolean;
};

export function DelayHelper(props: Props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { custom_rev_delay, delays, rev_delays } = data;
  const { delay_list, reverse = false } = props;

  return (
    <LabeledControls wrap>
      {delay_list.map((delay, i) => (
        <LabeledControls.Item
          key={i}
          label={custom_rev_delay ? '' : delay.title}
        >
          <Knob
            color={
              (reverse ? rev_delays[i + 1] : delays[i + 1]) / 10 > 10
                ? 'orange'
                : 'default'
            }
            format={(value) => toFixed(value, 2)}
            inline
            maxValue={10}
            minValue={0}
            onChange={(e, value) => {
              act('editTiming', {
                reverse: reverse,
                timer: `${i + 1}`,
                value: Math.max(value, 0),
              });
            }}
            size={custom_rev_delay ? 0.75 : 1}
            step={0.02}
            unclamped
            unit="s"
            value={(reverse ? rev_delays[i + 1] : delays[i + 1]) / 10}
          />
        </LabeledControls.Item>
      ))}
    </LabeledControls>
  );
}

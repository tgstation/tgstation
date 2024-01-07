import { toFixed } from 'common/math';

import { useBackend } from '../../backend';
import { Knob, LabeledControls } from '../../components';
import { PodLauncherData } from './types';


export function DelayHelper(props) {
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
            inline
            step={0.02}
            size={custom_rev_delay ? 0.75 : 1}
            value={(reverse ? rev_delays[i + 1] : delays[i + 1]) / 10}
            unclamped
            minValue={0}
            unit={'s'}
            format={(value) => toFixed(value, 2)}
            maxValue={10}
            color={
              (reverse ? rev_delays[i + 1] : delays[i + 1]) / 10 > 10
                ? 'orange'
                : 'default'
            }
            onDrag={(e, value) => {
              act('editTiming', {
                timer: '' + (i + 1),
                value: Math.max(value, 0),
                reverse: reverse,
              });
            }}
          />
        </LabeledControls.Item>
      ))}
    </LabeledControls>
  );
}

import { multiline } from 'common/string';

import { useBackend } from '../../backend';
import { Button, Divider, Section } from '../../components';
import { DELAYS, REV_DELAYS } from './constants';
import { DelayHelper } from './DelayHelper';
import { PodLauncherData } from './types';

export function Timing(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { custom_rev_delay, effectReverse } = data;

  return (
    <Section
      fill
      title="Time"
      buttons={
        <>
          <Button
            icon="undo"
            color="transparent"
            tooltip={multiline`
            Reset all pod
            timings/delays`}
            tooltipPosition="bottom-end"
            onClick={() => act('resetTiming')}
          />
          <Button
            icon={custom_rev_delay === 1 ? 'toggle-on' : 'toggle-off'}
            selected={custom_rev_delay}
            disabled={!effectReverse}
            color="transparent"
            tooltip={multiline`
            Toggle Reverse Delays
            Note: Top set is
            normal delays, bottom set
            is reversing pod's delays`}
            tooltipPosition="bottom-end"
            onClick={() => act('toggleRevDelays')}
          />
        </>
      }
    >
      <DelayHelper delay_list={DELAYS} />
      {custom_rev_delay && (
        <>
          <Divider />
          <DelayHelper delay_list={REV_DELAYS} reverse />
        </>
      )}
    </Section>
  );
}

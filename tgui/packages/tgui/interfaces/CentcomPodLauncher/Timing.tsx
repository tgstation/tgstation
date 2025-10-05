import { Button, Divider, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { DELAYS, REV_DELAYS } from './constants';
import { DelayHelper } from './DelayHelper';
import type { PodLauncherData } from './types';

export function Timing(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { custom_rev_delay, effectReverse } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            color="transparent"
            icon="undo"
            onClick={() => act('resetTiming')}
            tooltip={`
            Reset all pod
            timings/delays`}
            tooltipPosition="bottom-start"
          />
          <Button
            color="transparent"
            disabled={!effectReverse}
            icon={custom_rev_delay === 1 ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggleRevDelays')}
            selected={custom_rev_delay}
            tooltip={`
            Toggle Reverse Delays
            Note: Top set is
            normal delays, bottom set
            is reversing pod's delays`}
            tooltipPosition="bottom"
          />
        </>
      }
      fill
      title="Time"
    >
      <DelayHelper delay_list={DELAYS} />
      {!!custom_rev_delay && (
        <>
          <Divider />
          <DelayHelper delay_list={REV_DELAYS} reverse />
        </>
      )}
    </Section>
  );
}

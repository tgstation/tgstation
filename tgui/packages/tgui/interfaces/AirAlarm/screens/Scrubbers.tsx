import { useBackend } from 'tgui/backend';
import { NoticeBox, VirtualList } from 'tgui-core/components';

import { Scrubber } from '../../common/AtmosControls';
import { AirAlarmData } from '../types';

export function AirAlarmControlScrubbers(props) {
  const { data } = useBackend<AirAlarmData>();
  const { scrubbers } = data;

  if (!scrubbers || scrubbers.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        Nothing to show
      </NoticeBox>
    );
  }

  return (
    <VirtualList>
      {scrubbers.map((scrubber) => (
        <Scrubber key={scrubber.refID} {...scrubber} />
      ))}
    </VirtualList>
  );
}

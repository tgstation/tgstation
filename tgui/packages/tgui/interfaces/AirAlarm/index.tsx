import { useState } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { InterfaceLockNoticeBox } from '../common/InterfaceLockNoticeBox';
import { AirAlarmControl } from './AlarmControl';
import { AlarmEditingModal } from './AlarmModal';
import { AirAlarmStatus } from './AlarmStatus';
import type { ActiveModal, AirAlarmData } from './types';
import { ModalContext } from './useModal';

export function AirAlarm(props) {
  const { data } = useBackend<AirAlarmData>();
  const { tlvSettings } = data;

  const locked = data.locked && !data.siliconUser;

  const modalState = useState<ActiveModal>();
  const [activeModal, setActiveModal] = modalState;

  return (
    <ModalContext.Provider value={modalState}>
      <Window width={475} height={650}>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item mb={-1}>
              <InterfaceLockNoticeBox />
            </Stack.Item>
            <Stack.Item>
              <AirAlarmStatus />
            </Stack.Item>
            <Stack.Item grow>{!locked && <AirAlarmControl />}</Stack.Item>
          </Stack>
          {activeModal && (
            <AlarmEditingModal
              oldValue={
                tlvSettings.find((tlv) => tlv.id === activeModal.id)?.[
                  activeModal.typeVar
                ]
              }
              {...activeModal}
            />
          )}
        </Window.Content>
      </Window>
    </ModalContext.Provider>
  );
}

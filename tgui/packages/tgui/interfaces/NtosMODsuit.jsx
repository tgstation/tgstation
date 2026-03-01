import { NoticeBox } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { MODsuitContent } from './MODsuit';

export const NtosMODsuit = (props) => {
  const { data } = useBackend();
  const { ui_theme } = data;
  return (
    <NtosWindow theme={ui_theme}>
      <NtosWindow.Content scrollable>
        <NtosMODsuitContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const NtosMODsuitContent = (props) => {
  const { data } = useBackend();
  const { has_suit } = data;
  if (!has_suit) {
    return (
      <NoticeBox mt={1} mb={0} danger fontSize="12px">
        No Modular suit connected, please tap a suit on the application host to
        sync on
      </NoticeBox>
    );
  } else {
    return <MODsuitContent />;
  }
};

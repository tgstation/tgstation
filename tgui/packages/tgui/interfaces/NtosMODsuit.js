import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { NoticeBox } from '../components';
import { MODsuitContent } from './MODsuit';

export const NtosMODsuit = (props, context) => {
  const { data } = useBackend(context);
  const { ui_theme } = data;
  return (
    <NtosWindow theme={ui_theme}>
      <NtosWindow.Content scrollable>
        <NtosMODsuitContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const NtosMODsuitContent = (props, context) => {
  const { data } = useBackend(context);
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

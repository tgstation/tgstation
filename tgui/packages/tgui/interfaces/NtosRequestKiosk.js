import { RequestKioskContent } from './RequestKiosk';
import { NtosWindow } from '../layouts';

export const NtosRequestKiosk = (props, context) => {
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <RequestKioskContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

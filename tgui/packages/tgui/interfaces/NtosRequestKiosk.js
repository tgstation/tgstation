import { RequestKioskContent } from './RequestKiosk';
import { NtosWindow } from '../layouts';

export const NtosRequestKiosk = (props, context) => {
  return (
    <NtosWindow
      width={550}
      height={600}>
      <NtosWindow.Content scrollable>
        <RequestKioskContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

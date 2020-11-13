import { RdManagementContent } from './RdManagement.js';
import { NtosWindow } from '../layouts';

export const NtosCargo = (props, context) => {
  return (
    <NtosWindow
      width={1280}
      height={640}
      resizable>
      <NtosWindow.Content scrollable>
        <RdManagementContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

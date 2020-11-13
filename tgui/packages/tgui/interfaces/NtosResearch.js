import { RdManagementContent } from './RdManagement.js';
import { NtosWindow } from '../layouts';

export const NtosResearch = (props, context) => {
  return (
    <NtosWindow
      width={1280}
      height={640}
      resizable>
      <NtosWindow.Content>
        <RdManagementContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

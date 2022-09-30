import { NtosWindow } from '../layouts';
import { NtosCyborgRemoteMonitorContent } from './NtosCyborgRemoteMonitor';

export const NtosCyborgRemoteMonitorSyndicate = (props, context) => {
  return (
    <NtosWindow
      width={600}
      height={800}
      theme="syndicate">
      <NtosWindow.Content scrollable>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

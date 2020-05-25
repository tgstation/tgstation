import { NtosWindow } from '../layouts';
import { PowerMonitorContent } from './PowerMonitor';

export const NtosPowerMonitor = () => {
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <PowerMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

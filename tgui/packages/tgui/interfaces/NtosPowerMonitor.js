import { NtosWindow } from '../layouts';
import { PowerMonitorContent } from './PowerMonitor';

export const NtosPowerMonitor = () => {
  return (
    <NtosWindow
      width={550}
      height={700}
      resizable>
      <NtosWindow.Content scrollable>
        <PowerMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

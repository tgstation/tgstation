import { NtosWindow } from '../layouts';
import { PowerMonitorContent } from './PowerMonitor';

export const NtosPowerMonitor = (props) => {
  return (
    <NtosWindow width={550} height={700}>
      <NtosWindow.Content>
        <PowerMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

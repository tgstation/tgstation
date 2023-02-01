import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { PowerMonitorContent } from './PowerMonitor';

export const NtosPowerMonitor = (props, context) => {
  return (
    <NtosWindow width={550} height={700}>
      <NtosWindow.Content scrollable>
        <PowerMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

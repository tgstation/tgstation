import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { PowerMonitorContent } from './PowerMonitor';

type Data = {
  PC_device_theme: string;
};

export const NtosPowerMonitor = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow width={550} height={700} theme={PC_device_theme}>
      <NtosWindow.Content scrollable>
        <PowerMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

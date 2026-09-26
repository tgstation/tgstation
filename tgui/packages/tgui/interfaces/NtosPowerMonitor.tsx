import { NtosWindow } from '../layouts';
import { useNtos } from './NtosCore';
import { PowerMonitorContent, type PowerMonitorData } from './PowerMonitor';

export const NtosPowerMonitor = (props) => {
  const { data } = useNtos<PowerMonitorData>();

  return (
    <NtosWindow width={550} height={700}>
      <NtosWindow.Content>
        <PowerMonitorContent data={data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

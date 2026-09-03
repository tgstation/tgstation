import { NtosWindow } from '../layouts';
import {
  StatusDisplayControls,
  StatusDisplayControlsData,
} from './common/StatusDisplayControls';
import { useNtos } from './NtosCore';

export const NtosStatus = () => {
  const { act, data } = useNtos<StatusDisplayControlsData>();

  return (
    <NtosWindow width={400} height={350}>
      <NtosWindow.Content>
        <StatusDisplayControls act={act} data={data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

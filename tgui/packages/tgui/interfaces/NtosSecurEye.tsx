import { NtosWindow } from '../layouts';
import { type CameraConsoleData, CameraContent } from './CameraConsole';
import { useNtos } from './NtosCore';

export const NtosSecurEye = (props) => {
  const { act, data } = useNtos<CameraConsoleData>();

  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <CameraContent act={act} data={data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

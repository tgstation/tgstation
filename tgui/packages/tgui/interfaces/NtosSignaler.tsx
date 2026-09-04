import { NtosWindow } from '../layouts';
import { useNtos } from './NtosCore';
import { SignalerContent } from './Signaler';

export const NtosSignaler = () => {
  const { act, data } = useNtos();

  return (
    <NtosWindow width={400} height={300}>
      <NtosWindow.Content>
        <SignalerContent act={act} data={data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

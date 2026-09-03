import { NtosWindow } from '../layouts';
import { AiRestorerContent, AiRestorerData } from './AiRestorer';
import { useNtos } from './NtosCore';

export const NtosAiRestorer = (props) => {
  const { act, data } = useNtos<AiRestorerData>();

  return (
    <NtosWindow width={370} height={400}>
      <NtosWindow.Content scrollable>
        <AiRestorerContent act={act} data={data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

import { NtosWindow } from '../layouts';
import { AiRestorerContent } from './AiRestorer';

export const NtosAiRestorer = (props) => {
  return (
    <NtosWindow width={370} height={400}>
      <NtosWindow.Content scrollable>
        <AiRestorerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

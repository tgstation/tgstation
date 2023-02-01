import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { AiRestorerContent } from './AiRestorer';

export const NtosAiRestorer = (props, context) => {
  return (
    <NtosWindow width={370} height={400}>
      <NtosWindow.Content scrollable>
        <AiRestorerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

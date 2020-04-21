import { NtosWindow } from '../layouts';
import { AiRestorerContent } from './AiRestorer';

export const AiRestorer = () => {
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <AiRestorerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

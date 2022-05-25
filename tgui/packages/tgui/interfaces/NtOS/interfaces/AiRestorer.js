import { NtosWindow } from 'tgui/layouts';
import { AiRestorerContent } from '../../AiRestorer';

export const NtosAiRestorer = () => {
  return (
    <NtosWindow
      width={370}
      height={400}>
      <NtosWindow.Content scrollable>
        <AiRestorerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

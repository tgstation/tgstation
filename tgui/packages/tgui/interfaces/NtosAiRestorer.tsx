import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { AiRestorerContent } from './AiRestorer';

type Data = {
  PC_device_theme: string;
};

export const NtosAiRestorer = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow width={370} height={400} theme={PC_device_theme}>
      <NtosWindow.Content scrollable>
        <AiRestorerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

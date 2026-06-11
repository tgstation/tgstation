import { NtosWindow } from '../layouts';
import { RaptorDexContent } from './RaptorDex';

export const NtosRaptorDex = (props) => {
  return (
    <NtosWindow width={770} height={370}>
      <NtosWindow.Content scrollable>
        <RaptorDexContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

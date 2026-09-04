import { NtosWindow } from '../layouts';
import { useNtos } from './NtosCore';
import { RaptorDexContent, RaptorDexData } from './RaptorDex';

export const NtosRaptorDex = (props) => {
  const { data } = useNtos<RaptorDexData>();

  return (
    <NtosWindow width={770} height={370}>
      <NtosWindow.Content scrollable>
        <RaptorDexContent {...data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

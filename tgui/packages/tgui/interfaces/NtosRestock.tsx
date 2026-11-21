import { NtosWindow } from '../layouts';
import { useNtos } from './NtosCore';
import { RestockTracker } from './RestockTracker';

export const NtosRestock = (props) => {
  const { data } = useNtos();

  return (
    <NtosWindow width={575} height={560}>
      <NtosWindow.Content scrollable>
        <RestockTracker data={data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

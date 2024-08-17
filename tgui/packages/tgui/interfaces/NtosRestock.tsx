import { NtosWindow } from '../layouts';
import { RestockTracker } from './RestockTracker';

export const NtosRestock = (props) => {
  return (
    <NtosWindow width={575} height={560}>
      <NtosWindow.Content scrollable>
        <RestockTracker />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

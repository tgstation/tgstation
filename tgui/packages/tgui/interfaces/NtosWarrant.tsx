import { NtosWindow } from '../layouts';
import { WarrantConsole } from './WarrantConsole';

export const NtosWarrant = () => {
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <WarrantConsole />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

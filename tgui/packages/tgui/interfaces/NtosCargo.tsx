import { CargoContent } from './Cargo.js';
import { NtosWindow } from '../layouts';

export const NtosCargo = () => {
  return (
    <NtosWindow width={800} height={500}>
      <NtosWindow.Content scrollable>
        <CargoContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

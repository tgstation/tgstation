import { NtosWindow } from '../layouts';
import { CargoContent } from './Cargo';

export const NtosCargo = (props) => {
  return (
    <NtosWindow width={800} height={500}>
      <NtosWindow.Content scrollable>
        <CargoContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

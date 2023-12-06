import { CargoContent } from './Cargo';
import { NtosWindow } from '../layouts';

export const NtosCargo = (props) => {
  return (
    <NtosWindow width={800} height={500}>
      <NtosWindow.Content scrollable>
        <CargoContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

import { CargoContent } from '../../Cargo';
import { NtosWindow } from 'tgui/layouts';

export const NtosCargo = (props, context) => {
  return (
    <NtosWindow
      width={800}
      height={500}>
      <NtosWindow.Content scrollable>
        <CargoContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

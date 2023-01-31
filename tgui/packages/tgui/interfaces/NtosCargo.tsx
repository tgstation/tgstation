import { CargoContent } from './Cargo.js';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  PC_device_theme: string;
};

export const NtosCargo = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow width={800} height={500} theme={PC_device_theme}>
      <NtosWindow.Content scrollable>
        <CargoContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

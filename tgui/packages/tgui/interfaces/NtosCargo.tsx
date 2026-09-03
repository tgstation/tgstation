import { NtosWindow } from '../layouts';
import { CargoContent } from './Cargo';
import { CargoData } from './Cargo/types';
import { useNtos } from './NtosCore';

export const NtosCargo = (props) => {
  const { act, data } = useNtos<CargoData>();

  return (
    <NtosWindow width={800} height={500}>
      <NtosWindow.Content scrollable>
        <CargoContent act={act} data={data} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

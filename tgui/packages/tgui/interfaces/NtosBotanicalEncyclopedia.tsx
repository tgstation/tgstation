import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { type SeedData, SeedTable, type TraitData } from './SeedTable';

type Data = {
  seeds: SeedData[];
  trait_db: TraitData[];
  cycle_seconds: number;
};

export const NtosBotanicalEncyclopedia = (props) => {
  const { data } = useBackend<Data>();

  return (
    <NtosWindow width={800} height={700}>
      <NtosWindow.Content scrollable>
        <SeedTable
          seeds={data.seeds}
          trait_db={data.trait_db}
          cycle_seconds={data.cycle_seconds}
        />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

import { Button } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SeedTable, type SeedData, type TraitData } from './SeedTable';

type SeedExtractorData = {
  seeds: SeedData[];
  trait_db: TraitData[];
  cycle_seconds: number;
};

export const SeedExtractor = (props) => {
  const { act, data } = useBackend<SeedExtractorData>();

  return (
    <Window width={900} height={500}>
      <Window.Content scrollable>
        <SeedTable
          seeds={data.seeds}
          trait_db={data.trait_db}
          cycle_seconds={data.cycle_seconds}
          renderActions={(item) =>
            <>
              <Button icon="trash" content="Scrap" color="bad"
                onClick={() => act('scrap', { item: item.key })} />
              <Button icon="eject" content="Take" ml={1}
                onClick={() => act('take', { item: item.key })} />
            </>
          }
        />
      </Window.Content>
    </Window>
  );
};

import { Button, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PlantAnalyzerGraft } from './Graft';
import {
  PlantAnalyzerPlantChems,
  PlantAnalyzerSeedChems,
  PlantAnalyzerSeedStats,
} from './Seed';
import { PlantAnalyzerTrayChems, PlantAnalyzerTrayStats } from './Tray';
import type { PlantAnalyzerData } from './types';
import { PlantAnalyzerTabs } from './types';

export function PlantAnalyzer(props) {
  const { act, data } = useBackend<PlantAnalyzerData>();
  const { graft_data, seed_data, tray_data, plant_data, active_tab } = data;

  return (
    <Window width={475} height={625}>
      <Window.Content scrollable>
        <Section>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                align="center"
                onClick={() => act('setTab', { tab: PlantAnalyzerTabs.STATS })}
                selected={
                  active_tab === PlantAnalyzerTabs.STATS || !!graft_data
                }
              >
                Stats
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                align="center"
                fluid
                onClick={() => act('setTab', { tab: PlantAnalyzerTabs.CHEM })}
                selected={active_tab === PlantAnalyzerTabs.CHEM && !graft_data}
                disabled={!!graft_data}
              >
                Chemicals
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        {active_tab === PlantAnalyzerTabs.STATS || graft_data ? (
          <>
            {graft_data && <PlantAnalyzerGraft />}
            {tray_data && <PlantAnalyzerTrayStats />}
            {seed_data && <PlantAnalyzerSeedStats />}
          </>
        ) : (
          <>
            {/* grafts don't have any chems */}
            {tray_data && <PlantAnalyzerTrayChems />}
            {seed_data && <PlantAnalyzerSeedChems />}
            {plant_data && <PlantAnalyzerPlantChems />}
          </>
        )}
      </Window.Content>
    </Window>
  );
}

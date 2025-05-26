import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PlantAnalyzerGraft } from './Graft';
import { PlantAnalyzerSeed } from './Seed';
import { PlantAnalyzerTray } from './Tray';
import { PlantAnalyzerData } from './types';

export function PlantAnalyzer(props) {
  const { data } = useBackend<PlantAnalyzerData>();
  const { graft_data, seed_data, tray_data } = data;

  return (
    <Window width={480} height={520}>
      <Window.Content scrollable>
        {graft_data && <PlantAnalyzerGraft />}
        {seed_data && <PlantAnalyzerSeed />}
        {tray_data && <PlantAnalyzerTray />}
      </Window.Content>
    </Window>
  );
}

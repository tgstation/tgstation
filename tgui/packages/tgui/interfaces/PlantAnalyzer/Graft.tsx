import {
  DmIcon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { TraitTooltip } from '../SeedExtractor';
import { Fallback } from './Fallback';
import { PlantAnalyzerData } from './types';

export function PlantAnalyzerGraft(props) {
  const { data } = useBackend<PlantAnalyzerData>();
  const { graft_data } = data;

  return (
    <Section
      title={'Graft: ' + capitalizeFirst(graft_data.name)}
      buttons={
        !!graft_data.graft_gene && (
          <TraitTooltip path={graft_data.graft_gene} trait_db={data.trait_db} />
        )
      }
    >
      <Stack>
        <Stack.Item mx={2}>
          <DmIcon
            fallback={Fallback}
            icon={graft_data.icon}
            icon_state={graft_data.icon_state}
            height="64px"
            width="64px"
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Endurance">
              <ProgressBar
                value={graft_data.endurance / 100}
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.1, 0.5],
                  bad: [0, 0.1],
                }}
              >
                {graft_data.endurance} / 100
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Lifespan">
              <ProgressBar
                value={graft_data.lifespan / 100}
                ranges={{
                  good: [0.65, Infinity],
                  average: [0.25, 0.65],
                  bad: [0, 0.25],
                }}
              >
                {graft_data.lifespan} / 100
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Yield">
              <ProgressBar
                value={graft_data.yield / 10}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {graft_data.yield} / 10
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Instability">
              <ProgressBar
                value={graft_data.weed_chance}
                maxValue={100}
                ranges={{
                  good: [-Infinity, 20],
                  average: [20, 40],
                  bad: [40, Infinity],
                }}
              >
                {graft_data.weed_chance} / 100
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Production">
              {graft_data.production * data.cycle_seconds} seconds
            </LabeledList.Item>

            <LabeledList.Item label="Weeds">
              {graft_data.weed_chance && graft_data.weed_rate
                ? graft_data.weed_chance +
                  '% chance to grow by ' +
                  graft_data.weed_rate
                : 'No weed growth'}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

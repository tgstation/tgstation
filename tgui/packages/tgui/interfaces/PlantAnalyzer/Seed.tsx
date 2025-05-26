import {
  DmIcon,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { ReagentTooltip } from '../SeedExtractor';
import { TraitTooltip } from '../SeedExtractor';
import { Fallback } from './Fallback';
import { PlantAnalyzerData } from './types';

export function PlantAnalyzerSeed(props) {
  const { data } = useBackend<PlantAnalyzerData>();
  const { seed_data, tray_data } = data;

  return (
    <Section
      title={capitalizeFirst(seed_data.name)}
      buttons={<SeedExtraData />}
    >
      <Stack>
        <Stack.Item mx={2}>
          <DmIcon
            fallback={Fallback}
            icon={seed_data.icon}
            icon_state={seed_data.icon_state}
            height="64px"
            width="64px"
          />
          {seed_data.product_icon && seed_data.product_icon_state && (
            <DmIcon
              mt={2}
              fallback={Fallback}
              icon={seed_data.product_icon}
              icon_state={seed_data.product_icon_state}
              height="64px"
              width="64px"
            />
          )}
        </Stack.Item>
        <Stack.Item width="100%">
          <LabeledList>
            {tray_data && (
              <LabeledList.Item label="Health">
                <ProgressBar
                  value={tray_data.plant_health / seed_data.endurance}
                  ranges={{
                    good: [0.7, Infinity],
                    average: [0.3, 0.7],
                    bad: [0, 0.3],
                  }}
                >
                  {tray_data.plant_health} / {seed_data.endurance}
                </ProgressBar>
              </LabeledList.Item>
            )}

            <LabeledList.Item
              label="Endurance"
              tooltip="The health pool of the plant that delays withering. Improves quality of resulting food & drinks."
            >
              <ProgressBar
                value={seed_data.endurance / 100}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {seed_data.endurance} / 100
              </ProgressBar>
            </LabeledList.Item>

            {tray_data && (
              <LabeledList.Item label="Age">
                <ProgressBar
                  value={tray_data.plant_age}
                  maxValue={seed_data.lifespan}
                  ranges={{
                    average: [0, seed_data.maturation],
                    good: [seed_data.maturation, seed_data.lifespan],
                    bad: [seed_data.lifespan, Infinity],
                  }}
                >
                  {tray_data.plant_age * data.cycle_seconds} /{' '}
                  {seed_data.lifespan * data.cycle_seconds} seconds
                </ProgressBar>
              </LabeledList.Item>
            )}

            <LabeledList.Item
              label="Maturation"
              tooltip="The age at which the plant starts growing products."
            >
              {seed_data.maturation * data.cycle_seconds} seconds
            </LabeledList.Item>

            <LabeledList.Item
              label="Production"
              tooltip="The time needed for a mature plant to (re)grow a product."
            >
              {seed_data.production * data.cycle_seconds} seconds
            </LabeledList.Item>

            <LabeledList.Item
              label="Lifespan"
              tooltip={`The age at which the plant starts withering, in ${data.cycle_seconds} second long cycles. Improves quality of resulting food & drinks.`}
            >
              <ProgressBar
                value={seed_data.lifespan / 100}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {seed_data.lifespan} / 100
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label="Yield"
              tooltip="The number of products gathered in a single harvest."
            >
              <ProgressBar
                value={seed_data.yield / 10}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {seed_data.yield} / 10
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label="Potency"
              tooltip="Determines product mass, reagent volume and strength of effects."
            >
              <ProgressBar
                value={seed_data.potency / 100}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {seed_data.potency} / 100
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label="Instability"
              tooltip="The likelihood of the plant to randomize stats or mutate. Affects quality of resulting food & drinks."
            >
              <ProgressBar
                value={seed_data.instability}
                maxValue={100}
                ranges={{
                  good: [-Infinity, 20],
                  average: [20, 40],
                  bad: [40, Infinity],
                }}
              >
                {seed_data.instability} / 100
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Tray weeds">
              {seed_data.weed_chance && seed_data.weed_rate
                ? seed_data.weed_chance +
                  '% chance to grow by ' +
                  seed_data.weed_rate
                : 'No weed growth'}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function SeedExtraData(props) {
  const { data } = useBackend<PlantAnalyzerData>();
  const { seed_data } = data;

  return (
    <>
      {!!seed_data.graft_gene && (
        <TraitTooltip
          path={seed_data.graft_gene}
          trait_db={data.trait_db}
          grafting
        />
      )}

      {seed_data.removable_traits?.map((trait) => (
        <TraitTooltip key="" path={trait} trait_db={data.trait_db} removable />
      ))}
      {seed_data.core_traits?.map((trait) => (
        <TraitTooltip key="" path={trait} trait_db={data.trait_db} />
      ))}
      {!!seed_data.mutatelist.length && (
        <Tooltip content={`Mutates into: ${seed_data.mutatelist.join(', ')}`}>
          <Icon name="dna" m={0.5} />
        </Tooltip>
      )}
      {!!seed_data.juice_name && (
        <Tooltip content={`Juicing result: ${seed_data.juice_name}`}>
          <Icon name="glass-water" m={0.5} />
        </Tooltip>
      )}
      {!!seed_data.distill_reagent && (
        <Tooltip content={`Ferments into: ${seed_data.distill_reagent}`}>
          <Icon name="wine-bottle" m={0.5} />
        </Tooltip>
      )}
      {seed_data.reagents.length > 0 && (
        <Tooltip
          content={
            <ReagentTooltip
              reagents={seed_data.reagents}
              grind_results={seed_data.grind_results}
              potency={seed_data.potency}
              volume_mod={seed_data.volume_mod}
              volume_units={seed_data.volume_units}
            />
          }
        >
          <Icon name="blender" m={0.5} />
        </Tooltip>
      )}
    </>
  );
}

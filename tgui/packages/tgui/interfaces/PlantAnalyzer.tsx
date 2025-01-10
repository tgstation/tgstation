import {
  DmIcon,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ReagentTooltip, TraitTooltip } from './SeedExtractor';

export type PlantAnalyzerData = {
  tray_data: TrayData;
  seed_data: SeedData;
  graft_data: GraftData;
  // Static
  trait_db: TraitData[];
  cycle_seconds: number;
};

type TrayData = {
  plant_age: number;
  plant_health: number;
  name: string;
  icon: string;
  icon_state: string;
  water: number;
  water_max: number;
  nutri: number;
  nutri_max: number;
  yield_mod: number;
  weeds: number;
  weeds_max: number;
  pests: number;
  pests_max: number;
  toxins: number;
  toxins_max: number;
  reagents: ReagentVolume[];
};

type SeedData = {
  name: string;
  icon: string;
  icon_state: string;
  product: string;
  product_icon: string;
  product_icon_state: string;
  potency: number;
  yield: number;
  instability: number;
  maturation: number;
  production: number;
  lifespan: number;
  endurance: number;
  weed_rate: number;
  weed_chance: number;
  volume_mod: number;
  removable_traits: string[];
  core_traits: string[];
  graft_gene: string;
  mutatelist: string[];
  reagents: ReagentData[];
  grind_results: string[];
  distill_reagent: string;
  juice_name: string;
};

type GraftData = {
  name: string;
  icon: string;
  icon_state: string;
  yield: number;
  production: number;
  lifespan: number;
  endurance: number;
  weed_rate: number;
  weed_chance: number;
  graft_gene: string;
};

type ReagentVolume = {
  name: string;
  volume: string;
};

type ReagentData = {
  name: string;
  rate: string;
};

type TraitData = {
  path: string;
  name: string;
  icon: string;
  description: string;
};

const fallback_big = (
  <Icon name="spinner" size={2.8} height="32px" width="32px" spin />
);

export const PlantAnalyzer = (props) => {
  const { act, data } = useBackend<PlantAnalyzerData>();
  return (
    <Window width={480} height={500}>
      <Window.Content scrollable>
        {data.graft_data && <PlantAnalyzerGraft />}
        {data.seed_data && <PlantAnalyzerSeed />}
        {data.tray_data && <PlantAnalyzerTray />}
      </Window.Content>
    </Window>
  );
};

export const PlantAnalyzerTray = (props) => {
  const { act, data } = useBackend<PlantAnalyzerData>();
  const { tray_data } = data;
  return (
    <Section
      title={capitalizeFirst(tray_data.name)}
      buttons={
        tray_data.yield_mod > 1 && (
          <Tooltip content="Pollinated, doubling the yield.">
            <Icon name="sun" />
          </Tooltip>
        )
      }
    >
      <Stack>
        <Stack.Item ml={2} mr={4}>
          <DmIcon
            fallback={fallback_big}
            icon={tray_data.icon}
            icon_state={tray_data.icon_state}
            height="64px"
            width="64px"
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Water">
              <ProgressBar
                value={tray_data.water / tray_data.water_max}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {tray_data.water} / {tray_data.water_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Nutrients">
              <Tooltip
                content={
                  tray_data.reagents.length > 0 ? (
                    <ReagentList reagents={tray_data.reagents} />
                  ) : (
                    'No reagents detected.'
                  )
                }
              >
                <ProgressBar
                  value={tray_data.nutri / tray_data.nutri_max}
                  ranges={{
                    good: [0.7, Infinity],
                    average: [0.3, 0.7],
                    bad: [0, 0.3],
                  }}
                >
                  {tray_data.nutri} / {tray_data.nutri_max}
                </ProgressBar>
              </Tooltip>
            </LabeledList.Item>

            <LabeledList.Item label="Weeds">
              <ProgressBar
                value={tray_data.weeds}
                maxValue={tray_data.weeds_max}
                ranges={{
                  good: [-Infinity, 0],
                  average: [1, Math.round(tray_data.weeds_max * 0.5)],
                  bad: [Math.round(tray_data.weeds_max * 0.5), Infinity],
                }}
              >
                {tray_data.weeds} / {tray_data.weeds_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Pests">
              <ProgressBar
                value={tray_data.pests}
                maxValue={tray_data.pests_max}
                ranges={{
                  good: [-Infinity, 0],
                  average: [1, Math.round(tray_data.pests_max * 0.5)],
                  bad: [Math.round(tray_data.pests_max * 0.5), Infinity],
                }}
              >
                {tray_data.pests} / {tray_data.pests_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item label="Toxins">
              <ProgressBar
                value={tray_data.toxins}
                maxValue={tray_data.toxins_max}
                ranges={{
                  good: [-Infinity, 0],
                  average: [1, Math.round(tray_data.toxins_max * 0.5)],
                  bad: [Math.round(tray_data.toxins_max * 0.5), Infinity],
                }}
              >
                {tray_data.toxins} / {tray_data.toxins_max}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const PlantAnalyzerSeed = (props) => {
  const { act, data } = useBackend<PlantAnalyzerData>();
  const { seed_data, tray_data } = data;
  return (
    <Section
      title={capitalizeFirst(seed_data.name)}
      buttons={<SeedExtraData />}
    >
      <Stack>
        <Stack.Item ml={2} mr={4}>
          <DmIcon
            fallback={fallback_big}
            icon={seed_data.icon}
            icon_state={seed_data.icon_state}
            height="64px"
            width="64px"
          />
          {seed_data.product_icon && seed_data.product_icon_state && (
            <DmIcon
              mt={2}
              fallback={fallback_big}
              icon={seed_data.product_icon}
              icon_state={seed_data.product_icon_state}
              height="64px"
              width="64px"
            />
          )}
        </Stack.Item>
        <Stack.Item>
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
              tooltip="The health pool of the plant that delays death. Improves quality of resulting food & drinks."
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
              label="Lifespan"
              tooltip={`The age at which the plant starts decaying, in ${data.cycle_seconds} second long cycles. Improves quality of resulting food & drinks.`}
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

            <LabeledList.Item label="Weeds">
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
};

export const SeedExtraData = (props) => {
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
            />
          }
        >
          <Icon name="blender" m={0.5} />
        </Tooltip>
      )}
    </>
  );
};

export const PlantAnalyzerGraft = (props) => {
  const { act, data } = useBackend<PlantAnalyzerData>();
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
        <Stack.Item ml={2} mr={4}>
          <DmIcon
            fallback={fallback_big}
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

            <LabeledList.Item label="Production">
              {graft_data.production * data.cycle_seconds} seconds
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

            <LabeledList.Item label="Potency">
              <ProgressBar
                value={graft_data.weed_rate / 100}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                {graft_data.weed_rate} / 100
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
};

export const ReagentList = (props) => {
  return (
    <Table>
      <Table.Row header>
        <Table.Cell colSpan={2}>Reagents:</Table.Cell>
      </Table.Row>
      {props.reagents?.map((reagent, i) => (
        <Table.Row key={i}>
          <Table.Cell>{reagent.name}</Table.Cell>
          <Table.Cell py={0.5} pl={2} textAlign={'right'}>
            {reagent.volume}u
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

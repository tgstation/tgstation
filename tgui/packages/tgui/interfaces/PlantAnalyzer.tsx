import { useState } from 'react';
import {
  Box,
  DmIcon,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export type PlantAnalyzerData = {
  tray_data: TrayData;
  seed_data: SeedData;
};

type TrayData = {
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
};

const fallback = (
  <Icon name="spinner" size={5} height="64px" width="64px" spin />
);

type SeedData = {
  name: string;
  icon: string;
  icon_state: string;
  fruit: string;
  fruit_icon: string;
  fruit_icon_state: string;
  potency: number;
  yield: number;
  instability: number;
  maturation: number;
  production: number;
  lifespan: number;
  endurance: number;
  genes: [string];
};

export const PlantAnalyzer = (props) => {
  const { act, data } = useBackend<PlantAnalyzerData>();
  const [tabIndex, setTabIndex] = useState(0);
  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        <Tabs fluid mb={0}>
          <Tabs.Tab
            icon="seedling"
            key={0}
            selected={tabIndex === 0}
            onClick={() => setTabIndex(0)}
          >
            Seed
          </Tabs.Tab>
          <Tabs.Tab
            icon="glass-water-droplet"
            key={1}
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}
          >
            Tray
          </Tabs.Tab>
        </Tabs>
        {tabIndex === 0 && <PlantAnalyzerSeed />}
        {tabIndex === 1 && <PlantAnalyzerTray />}
      </Window.Content>
    </Window>
  );
};

export const PlantAnalyzerTray = (props) => {
  const { act, data } = useBackend<PlantAnalyzerData>();
  const { tray_data } = data;
  return (
    <Section title={tray_data.name}>
      <Stack>
        <Stack.Item ml={2} mr={4}>
          <DmIcon
            fallback={fallback}
            icon={tray_data.icon}
            icon_state={tray_data.icon_state}
            height="64px"
            width="64px"
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
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
    <Section title={seed_data.name}>
      <Stack>
        <Stack.Item ml={2} mr={4}>
          <DmIcon
            fallback={fallback}
            icon={seed_data.icon}
            icon_state={seed_data.icon_state}
            height="64px"
            width="64px"
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Health">
              <ProgressBar
                value={10 / seed_data.endurance}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [0, 0.3],
                }}
              >
                10 / {seed_data.endurance}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <ProgressBar
                value={10}
                maxValue={seed_data.lifespan}
                ranges={{
                  average: [0, seed_data.maturation],
                  good: [seed_data.maturation, seed_data.lifespan],
                  bad: [seed_data.lifespan, Infinity],
                }}
              >
                10 / {seed_data.lifespan}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Maturation">
              {seed_data.maturation} cycles
            </LabeledList.Item>
            <LabeledList.Item label="Produce">
              {seed_data.yield * tray_data.yield_mod}x
              <DmIcon
                fallback={fallback}
                icon={seed_data.fruit_icon}
                icon_state={seed_data.fruit_icon_state}
                height="16px"
                width="16px"
                mb="-4px"
              />
              {seed_data.fruit} every {seed_data.production} cycles
            </LabeledList.Item>
            <LabeledList.Item label="Potency">
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
            <LabeledList.Item label="Yield">
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
            <LabeledList.Item label="Instability">
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
            <LabeledList.Item label="Genes">
              {seed_data.genes.map((g) => (
                <Box key={g}>{g}</Box>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

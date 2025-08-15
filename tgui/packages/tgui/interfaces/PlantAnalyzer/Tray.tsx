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

import { useBackend } from '../../backend';
import { Fallback } from './Fallback';
import type { PlantAnalyzerData } from './types';

export function PlantAnalyzerTray(props) {
  const { data } = useBackend<PlantAnalyzerData>();
  const { tray_data } = data;

  return (
    <Section
      title={capitalizeFirst(tray_data.name)}
      buttons={
        <>
          {!!tray_data.self_sustaining && (
            <Tooltip content="Self sustaining active, providing light, reclaiming water and reducing weed and pest levels.">
              <Icon name="hand-holding-droplet" m={0.5} />
            </Tooltip>
          )}
          {!!tray_data.being_pollinated && (
            <Tooltip content="Cross pollinating nearby plants, potentially sharing plant reagents.">
              <Icon name="wind" m={0.5} />
            </Tooltip>
          )}
          {tray_data.yield_mod > 1 && (
            <Tooltip content="Pollinated by bees, doubling the yield.">
              <Icon name="sun" m={0.5} />
            </Tooltip>
          )}
        </>
      }
    >
      <Stack>
        <Stack.Item mx={2}>
          <DmIcon
            fallback={Fallback}
            icon={tray_data.icon}
            icon_state={tray_data.icon_state}
            height="64px"
            width="64px"
          />
        </Stack.Item>
        <Stack.Item width="100%">
          <LabeledList>
            <LabeledList.Item
              label="Water"
              tooltip="The plant starts withering without water, unless it is a mushroom."
            >
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

            <LabeledList.Item
              label="Nutrients"
              tooltip="The plant starts withering without nutrients, unless it is a weed. Nutrients may affect plant and tray stats."
            >
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

            <LabeledList.Item
              label="Light"
              tooltip="The plant withers when the light is below 40%. Mushrooms need only 20%."
            >
              <ProgressBar
                value={tray_data.light_level}
                maxValue={1}
                ranges={{
                  bad: [0, 0.2],
                  average: [0.2, 0.4],
                  good: [0.4, Infinity],
                }}
              >
                {Math.round(tray_data.light_level * 100)}%
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label="Weeds"
              tooltip="Damage the Yield stat of the plant. At high level may invade the tray. Remove by cultivating."
            >
              <ProgressBar
                value={tray_data.weeds}
                maxValue={tray_data.weeds_max}
                ranges={{
                  good: [-Infinity, 5],
                  average: [5, 10],
                  bad: [10, tray_data.weeds_max],
                }}
              >
                {tray_data.weeds} / {tray_data.weeds_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label="Pests"
              tooltip="Damage the plant and reduce its Potency stat. Remove with pest controlling nutrients."
            >
              <ProgressBar
                value={tray_data.pests}
                maxValue={tray_data.pests_max}
                ranges={{
                  good: [-Infinity, 4],
                  average: [4, 8],
                  bad: [8, tray_data.pests_max],
                }}
              >
                {tray_data.pests} / {tray_data.pests_max}
              </ProgressBar>
            </LabeledList.Item>

            <LabeledList.Item
              label="Toxins"
              tooltip="Damage the plant. Remove with detoxing nutrients."
            >
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
}

function ReagentList(props) {
  const { reagents = [] } = props;

  return (
    <Table>
      <Table.Row header>
        <Table.Cell colSpan={2}>Reagents:</Table.Cell>
      </Table.Row>
      {reagents.map((reagent, i) => (
        <Table.Row key={i}>
          <Table.Cell>{reagent.name}</Table.Cell>
          <Table.Cell py={0.5} pl={2} textAlign="right">
            {reagent.volume}u
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}

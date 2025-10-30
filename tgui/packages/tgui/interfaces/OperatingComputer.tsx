import '../styles/interfaces/OperatingComputer.scss';
import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll, capitalizeFirst, createSearch } from 'tgui-core/string';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { BodyZone, BodyZoneSelector } from './common/BodyZoneSelector';
import {
  Experiment,
  type ExperimentData,
  type Techweb,
  TechwebServer,
} from './ExperimentConfigure';

type damageType = {
  label: string;
  type: 'bruteLoss' | 'fireLoss' | 'toxLoss' | 'oxyLoss';
};

const damageTypes: damageType[] = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Respiratory',
    type: 'oxyLoss',
  },
];

enum ComputerTabs {
  PatientState = 1,
  OperationCatalog = 2,
  Experiments = 3,
}

export const OperatingComputer = () => {
  const [tab, setTab] = useSharedState('tab', 1);
  const [searchText, setSearchText] = useState('');

  return (
    <Window
      width={tab === ComputerTabs.PatientState ? 345 : 415}
      height={610}
      theme="operating_computer"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === ComputerTabs.PatientState}
                onClick={() => setTab(1)}
              >
                Patient State
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === ComputerTabs.OperationCatalog}
                onClick={() => setTab(2)}
              >
                Operation Catalog
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === ComputerTabs.Experiments}
                onClick={() => setTab(3)}
              >
                Experiments
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === ComputerTabs.PatientState && (
              <PatientStateView setTab={setTab} setSearchText={setSearchText} />
            )}
            {tab === ComputerTabs.OperationCatalog && (
              <SurgeryProceduresView
                searchText={searchText}
                setSearchText={setSearchText}
              />
            )}
            {tab === ComputerTabs.Experiments && <ExperimentView />}
          </Stack.Item>
          <Stack.Item textAlign="right" color="label" fontSize="0.7em">
            <Section>
              DefOS 1.0 &copy; Nanotrasen-Deforest Corporation. All rights
              reserved.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type PatientData = {
  health: number;
  blood_type: string;
  stat: 'Conscious' | 'Unconscious' | 'Dead';
  statstate: 'good' | 'average' | 'bad';
  minHealth: number;
  maxHealth: number;
  bruteLoss: number;
  fireLoss: number;
  toxLoss: number;
  oxyLoss: number;
  blood_level: number;
  standard_blood_level: number;
  target_zone: BodyZone;
  has_limbs: BooleanLike;
  surgery_state: string[];
};

type OperationData = {
  name: string;
  desc: string;
  tool_rec: string;
  // show operation as a recommended next step
  show_as_next: BooleanLike;
  // show operation in the full list
  show_in_list: BooleanLike;
};

type Data = {
  has_table: BooleanLike;
  patient?: PatientData;
  target_zone: BodyZone;
  // static data
  surgeries: OperationData[];
  techwebs: Techweb[];
  experiments: ExperimentData[];
};

function formatSurgeryName(
  operation: OperationData,
  catalog: boolean,
): { name: string; tool: string; true_name?: string } {
  // operation names may be "make incision", "lobotomy", or "disarticulation (amputation)"
  const { name, tool_rec } = operation;
  const parenthesis = name.indexOf('(');
  if (parenthesis === -1) {
    return { name: capitalizeFirst(name), tool: tool_rec };
  }
  const in_parenthesis = name.slice(parenthesis + 1, name.indexOf(')')).trim();
  if (!catalog) {
    return {
      name: capitalizeFirst(in_parenthesis),
      tool: tool_rec,
    };
  }
  const out_parenthesis = capitalizeFirst(name.slice(0, parenthesis).trim());
  return {
    name: capitalizeFirst(out_parenthesis),
    tool: tool_rec,
    true_name: capitalizeFirst(in_parenthesis),
  };
}

type PatientStateViewProps = {
  setTab: (tab: number) => void;
  setSearchText: (text: string) => void;
};

const PatientStateView = (props: PatientStateViewProps) => {
  const { act, data } = useBackend<Data>();
  const { setTab, setSearchText } = props;

  const { has_table, patient, target_zone, surgeries } = data;
  if (!has_table) {
    return (
      <Section fill>
        <NoticeBox color="yellow" align="center">
          No table detected
        </NoticeBox>
      </Section>
    );
  }
  if (!patient) {
    return (
      <Section fill>
        <NoticeBox color="red" align="center">
          No patient detected
        </NoticeBox>
      </Section>
    );
  }
  const possible_next_operations = surgeries.filter(
    (operation) => operation.show_as_next,
  );

  const allTools = ['all tools'].concat(
    possible_next_operations
      .map((operation) => operation.tool_rec)
      .flatMap((tool) => tool.split(' / '))
      .filter((tools, index, self) => self.indexOf(tools) === index),
  );

  const [filterByTool, setFilterByTool] = useSharedState<string>(
    'filter_by_tool',
    allTools[0],
  );

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="State" color={patient.statstate}>
              {patient.stat}
            </LabeledList.Item>
            <LabeledList.Item label="Blood Type">
              {patient.blood_type || 'Unable to determine blood type'}
            </LabeledList.Item>
            <LabeledList.Item label="Health">
              <ProgressBar
                value={patient.health}
                minValue={patient.minHealth}
                maxValue={patient.maxHealth}
                color={patient.health >= 0 ? 'good' : 'average'}
              >
                <AnimatedNumber
                  value={patient.health}
                  format={(value) => `${Math.round(value)}%`}
                />
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Blood Level">
              <ProgressBar
                value={patient.blood_level}
                minValue={0}
                maxValue={patient.standard_blood_level}
                color={
                  patient.blood_level >= patient.standard_blood_level * 0.7
                    ? 'good'
                    : patient.blood_level >= patient.standard_blood_level * 0.45
                      ? 'average'
                      : 'bad'
                }
              >
                <AnimatedNumber
                  value={patient.blood_level / patient.standard_blood_level}
                  format={(value) => `${Math.round(value * 100)}%`}
                />
              </ProgressBar>
            </LabeledList.Item>
            {damageTypes.map((type) => (
              <LabeledList.Item key={type.type} label={type.label}>
                <ProgressBar
                  value={patient[type.type] / patient.maxHealth}
                  color="bad"
                >
                  <AnimatedNumber value={patient[type.type]} />
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Stack.Item>
        <Stack.Item p={1}>
          <Stack>
            <Stack.Item>
              <BodyZoneSelector
                precise={false}
                theme="slimecore"
                onClick={
                  // no limbs = don't allow changing zones
                  patient.has_limbs
                    ? (zone) =>
                        zone !== target_zone &&
                        act('change_zone', { new_zone: zone })
                    : undefined
                }
                selectedZone={
                  // no limbs = default to chest
                  patient.has_limbs ? target_zone : BodyZone.Chest
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                {patient.surgery_state.map((state) => (
                  <Stack.Item key={state}>- {state}</Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title="Possible Operations"
            scrollable
            fill
            buttons={
              <Button
                icon="filter"
                tooltip="Filter by recommended tool. Right click to reset."
                tooltipPosition="top"
                onClick={() =>
                  setFilterByTool(
                    allTools[
                      (allTools.indexOf(filterByTool) + 1) % allTools.length
                    ],
                  )
                }
                onContextMenu={() => setFilterByTool(allTools[0])}
              >
                {capitalizeFirst(filterByTool)}
              </Button>
            }
          >
            <Stack vertical fill>
              {possible_next_operations.length === 0 ? (
                <Stack.Item>
                  <NoticeBox color="green" align="center">
                    No operations available
                  </NoticeBox>
                </Stack.Item>
              ) : (
                possible_next_operations
                  .filter((operation) =>
                    filterByTool === allTools[0]
                      ? true
                      : operation.tool_rec.includes(filterByTool),
                  )
                  .map((operation) => {
                    const { name, tool } = formatSurgeryName(operation, false);
                    return (
                      <Stack.Item key={operation.name}>
                        <Button
                          fluid
                          disabled={!operation.show_in_list}
                          tooltip={operation.desc}
                          onClick={() => {
                            setTab(ComputerTabs.OperationCatalog);
                            setSearchText(operation.name);
                          }}
                        >
                          {`- ${name} (${tool})`}
                        </Button>
                      </Stack.Item>
                    );
                  })
              )}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type SurgeryProceduresViewProps = {
  searchText: string;
  setSearchText: (text: string) => void;
};

const SurgeryProceduresView = (props: SurgeryProceduresViewProps) => {
  const { data } = useBackend<Data>();
  const { surgeries } = data;
  const { searchText, setSearchText } = props;
  const [sortType, setSortType] = useState<'default' | 'name' | 'tool'>(
    'default',
  );

  const searchFilter = createSearch(
    searchText,
    (surgery: OperationData) =>
      surgery.name + ' ' + surgery.tool_rec + ' ' + surgery.desc,
  );

  // - filter unlisted surgeries
  // - then filter dupe names (for surgeries which may have subtypes)
  // - then finally filter by search
  // and then apply sorting
  const surgeryList = surgeries
    .filter((surgery) => surgery.show_in_list)
    .filter(
      (surgery, index, self) =>
        index === self.findIndex((s) => s.name === surgery.name),
    )
    .filter((surgery) => searchFilter(surgery));

  if (sortType === 'name') {
    surgeryList.sort((a, b) => (a.name > b.name ? 1 : -1));
  } else if (sortType === 'tool') {
    surgeryList.sort((a, b) => (a.tool_rec > b.tool_rec ? 1 : -1));
  }

  return (
    <Section
      title="&nbsp;"
      scrollable
      fill
      buttons={
        <>
          <Button
            width="75px"
            icon="sort"
            tooltip="Cycle between sorting methods."
            onClick={() =>
              setSortType(
                sortType === 'default'
                  ? 'name'
                  : sortType === 'name'
                    ? 'tool'
                    : 'default',
              )
            }
          >
            {capitalizeFirst(sortType)}
          </Button>
          <Input
            width="200px"
            placeholder="Search..."
            value={searchText}
            onChange={setSearchText}
          />
        </>
      }
    >
      {surgeryList.map((surgery) => {
        const { name, tool, true_name } = formatSurgeryName(surgery, true);
        return (
          <Stack vertical key={surgery.name} pb={2}>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item bold>{name}</Stack.Item>
                {!!true_name && (
                  <Stack.Item italic fontSize="0.9rem">
                    {`(${true_name})`}
                  </Stack.Item>
                )}
                <Stack.Item grow />
                <Stack.Item italic textAlign="right" fontSize="0.9rem">
                  {capitalizeAll(tool)}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Box
                style={{
                  borderStyle: 'solid',
                  borderBottom: '0',
                  borderRight: '0',
                  borderWidth: '2px',
                  paddingTop: '2px',
                  paddingLeft: '4px',
                }}
                color="label"
              >
                {surgery.desc}
              </Box>
            </Stack.Item>
          </Stack>
        );
      })}
    </Section>
  );
};

const ExperimentView = () => {
  const { act, data } = useBackend<Data>();
  const { techwebs, experiments } = data;

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          title="Servers"
          fill
          buttons={
            <Button onClick={() => act('open_experiments')}>Open Config</Button>
          }
        >
          <TechwebServer techwebs={techwebs} can_select={false} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical fill>
          {techwebs.some((e) => e.selected) && (
            <Stack.Item>
              <Section title="Experiments" scrollable>
                {experiments.length > 0 ? (
                  experiments
                    .sort((a, b) => (a.name > b.name ? 1 : -1))
                    .map((exp, i) => (
                      <Experiment key={i} exp={exp} can_select={false} />
                    ))
                ) : (
                  <NoticeBox color="yellow">No experiments found!</NoticeBox>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

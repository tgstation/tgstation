import '../styles/interfaces/OperatingComputer.scss';
import { useState } from 'react';
import {
  AnimatedNumber,
  Blink,
  Box,
  Button,
  Collapsible,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll, capitalizeFirst } from 'tgui-core/string';
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
  const { data } = useBackend<Data>();
  const { surgeries } = data;

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: surgeries,
    matchStrategy: 'aggressive',
    getSearchString: (item: OperationData) => `${item.name} ${item.tool_rec}`,
  });

  const [pinnedOperations, setPinnedOperations] = useSharedState<string[]>(
    'pinned_operation',
    [],
  );

  return (
    <Window
      width={tab === ComputerTabs.PatientState ? 350 : 430}
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
              <PatientStateView
                setTab={setTab}
                setSearchText={setQuery}
                pinnedOperations={pinnedOperations}
                setPinnedOperations={setPinnedOperations}
              />
            )}
            {tab === ComputerTabs.OperationCatalog && (
              <SurgeryProceduresView
                searchedSurgeries={results}
                searchText={query}
                setSearchText={setQuery}
                pinnedOperations={pinnedOperations}
                setPinnedOperations={setPinnedOperations}
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
  priority?: BooleanLike;
  mechanic?: BooleanLike;
  requirements?: string[][];
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

function extractSurgeryName(
  operation: OperationData,
  catalog: boolean,
): { name: string; tool: string; true_name?: string } {
  // operation names may be "make incision", "lobotomy", or "disarticulation (amputation)"
  const { name, tool_rec } = operation;
  if (!name) {
    return { name: 'Error Surgery', tool: 'Error' };
  }
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
  pinnedOperations: string[];
  setPinnedOperations: (text: string[]) => void;
};

const PatientStateView = (props: PatientStateViewProps) => {
  const { act, data } = useBackend<Data>();
  const { setTab, setSearchText, pinnedOperations, setPinnedOperations } =
    props;

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

  if (filterByTool !== allTools[0]) {
    possible_next_operations.filter((operation) =>
      operation.tool_rec.includes(filterByTool),
    );
  }

  if (pinnedOperations.length > 0) {
    possible_next_operations.sort((a, b) => {
      if (
        pinnedOperations.includes(a.name) &&
        !pinnedOperations.includes(b.name)
      ) {
        return -1;
      }
      if (
        !pinnedOperations.includes(a.name) &&
        pinnedOperations.includes(b.name)
      ) {
        return 1;
      }
      return 0;
    });
  }

  possible_next_operations.sort((a, b) => (a.priority && !b.priority ? -1 : 1));

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
                selected={filterByTool !== allTools[0]}
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
                possible_next_operations.map((operation) => {
                  const { name, tool } = extractSurgeryName(operation, false);
                  return (
                    <Stack.Item key={operation.name}>
                      <Button
                        fluid
                        disabled={!operation.show_in_list}
                        tooltip={
                          <Stack vertical>
                            {!!operation.priority && (
                              <Stack.Item color="orange">
                                <Icon name="exclamation" mr={1} />
                                Recommended next step
                              </Stack.Item>
                            )}
                            {pinnedOperations.includes(operation.name) && (
                              <Stack.Item color="yellow">
                                <Icon name="thumbtack" mr={1} />
                                Pinned
                              </Stack.Item>
                            )}
                            <Stack.Item>{operation.desc}</Stack.Item>
                            <Stack.Item italic fontSize="0.9rem">
                              {`Left click ${
                                pinnedOperations.includes(operation.name)
                                  ? 'unpins operation from'
                                  : 'pins operation to'
                              } the top.`}
                            </Stack.Item>
                            <Stack.Item italic fontSize="0.9rem">
                              Right click opens operation info.
                            </Stack.Item>
                          </Stack>
                        }
                        tooltipPosition="bottom"
                        color={
                          operation.priority
                            ? 'caution'
                            : pinnedOperations.includes(operation.name)
                              ? 'danger'
                              : undefined
                        }
                        onContextMenu={() => {
                          setTab(ComputerTabs.OperationCatalog);
                          setSearchText(operation.name);
                        }}
                        onClick={() => {
                          setPinnedOperations(
                            pinnedOperations.includes(operation.name)
                              ? pinnedOperations.filter(
                                  (op) => op !== operation.name,
                                )
                              : pinnedOperations.concat(operation.name),
                          );
                        }}
                      >
                        <Stack fill>
                          <Stack.Item
                            style={{
                              textOverflow: 'ellipsis',
                              overflow: 'hidden',
                            }}
                          >
                            {name}
                          </Stack.Item>
                          {!!operation.priority && (
                            <Stack.Item>
                              <Blink interval={500} time={500}>
                                <Icon name="exclamation" />
                              </Blink>
                            </Stack.Item>
                          )}
                          {pinnedOperations.includes(operation.name) && (
                            <Stack.Item>
                              <Icon name="thumbtack" />
                            </Stack.Item>
                          )}
                          <Stack.Item grow />
                          <Stack.Item italic fontSize="0.9rem">
                            {capitalizeAll(tool)}
                          </Stack.Item>
                        </Stack>
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

type SurgeryRequirementsInnerProps = {
  cat_text: string;
  cat_contents: string[];
};

const SurgeryRequirementsInner = (props: SurgeryRequirementsInnerProps) => {
  const { cat_text, cat_contents } = props;

  return (
    <Stack.Item>
      <Stack.Item italic pb={1}>
        {cat_text}
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          {cat_contents.map((req, i) => (
            <Stack.Item key={i}>- {capitalizeFirst(req)}</Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </Stack.Item>
  );
};

function extractRequirementMap(
  surgery: OperationData,
): Record<string, string[]> {
  if (surgery.requirements?.length !== 4) {
    return {}; // we can assert this never happens, but just in case...
  }
  const hard_requirements = surgery.requirements[0];
  const soft_requirements = surgery.requirements[1];
  const optional_requirements = surgery.requirements[2];
  const blocked_requirements = surgery.requirements[3];

  // you *have* to have one of the soft requirements, so if there's only one...
  if (soft_requirements.length === 1) {
    hard_requirements.push(soft_requirements[0]);
    soft_requirements.length = 0;
  }

  const optional_title = () => {
    if (optional_requirements.length === 1) {
      if (hard_requirements.length === 0) return 'The following is optional:';
      return 'Additionally, the following is optional:';
    }
    if (hard_requirements.length === 0)
      return 'All of the following are optional:';
    return 'Additionally, all of the following are optional:';
  };

  const blocked_title = () => {
    if (blocked_requirements.length === 1) {
      if (hard_requirements.length === 0)
        return 'The following would block the procedure:';
      return 'However, the following would block the procedure:';
    }
    if (hard_requirements.length === 0)
      return 'Any of the following would block the procedure:';
    return 'However, any of the following would block the procedure:';
  };

  return {
    [`${hard_requirements.length === 1 ? 'The' : 'All of the'} following are required:`]:
      hard_requirements,
    'Additionally, one of the following is required:': soft_requirements,
    [optional_title()]: optional_requirements,
    [blocked_title()]: blocked_requirements,
  };
}

type SurgeryProceduresViewProps = {
  searchedSurgeries: OperationData[];
  searchText: string;
  setSearchText: (text: string) => void;
  pinnedOperations: string[];
  setPinnedOperations: (text: string[]) => void;
};

const SurgeryProceduresView = (props: SurgeryProceduresViewProps) => {
  const { data } = useBackend<Data>();
  const { surgeries } = data;
  const {
    searchedSurgeries,
    searchText,
    setSearchText,
    pinnedOperations,
    setPinnedOperations,
  } = props;
  const [sortType, setSortType] = useState<'default' | 'name' | 'tool'>(
    'default',
  );
  const [filterRobotic, setFilterRobotic] = useState(false);
  const rawSurgeryList =
    searchedSurgeries.length > 0 ? searchedSurgeries : surgeries;

  const surgeryList = rawSurgeryList
    .filter((surgery) => surgery.show_in_list)
    .filter((surgery) => !filterRobotic || !surgery.mechanic)
    .filter(
      (surgery, index, self) =>
        index === self.findIndex((s) => s.name === surgery.name),
    );

  if (sortType === 'name') {
    surgeryList.sort((a, b) => (a.name > b.name ? 1 : -1));
  } else if (sortType === 'tool') {
    surgeryList.sort((a, b) => (a.tool_rec > b.tool_rec ? 1 : -1));
  }

  if (pinnedOperations.length > 0) {
    surgeryList.sort((a, b) => {
      if (
        pinnedOperations.includes(a.name) &&
        !pinnedOperations.includes(b.name)
      ) {
        return -1;
      }
      if (
        !pinnedOperations.includes(a.name) &&
        pinnedOperations.includes(b.name)
      ) {
        return 1;
      }
      return 0;
    });
  }

  return (
    <Section
      title="&nbsp;"
      scrollable
      fill
      buttons={
        <>
          <Button
            icon="filter"
            tooltip="Filter out robotic surgeries."
            onClick={() => setFilterRobotic((state) => !state)}
            selected={filterRobotic}
          >
            Hide Mechanic
          </Button>
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
        const { name, tool, true_name } = extractSurgeryName(surgery, true);

        return (
          <Stack vertical key={surgery.name} pb={2}>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="thumbtack"
                        tooltipPosition="top"
                        color={
                          pinnedOperations.includes(surgery.name)
                            ? 'danger'
                            : undefined
                        }
                        onClick={() =>
                          setPinnedOperations(
                            pinnedOperations.includes(surgery.name)
                              ? pinnedOperations.filter(
                                  (op) => op !== surgery.name,
                                )
                              : pinnedOperations.concat(surgery.name),
                          )
                        }
                      />
                    </Stack.Item>
                    <Stack.Item bold fontSize="1.2rem">
                      {name}
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
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
                <Stack vertical>
                  <Stack.Item bold>{surgery.desc}</Stack.Item>
                  <Stack.Item>
                    <Collapsible
                      title="Requirements"
                      open={pinnedOperations.includes(surgery.name)}
                    >
                      <Stack
                        pl={1}
                        ml={0.5}
                        style={{
                          borderStyle: 'dashed',
                          borderBottom: '0',
                          borderRight: '0',
                          borderTop: '0',
                          borderWidth: '2px',
                          flexDirection: 'column',
                        }}
                      >
                        {Object.entries(extractRequirementMap(surgery)).map(
                          ([cat_text, cat_contents], i) =>
                            cat_contents.length > 0 ? (
                              <SurgeryRequirementsInner
                                key={i}
                                cat_text={cat_text}
                                cat_contents={cat_contents}
                              />
                            ) : null,
                        )}
                      </Stack>
                    </Collapsible>
                  </Stack.Item>
                </Stack>
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

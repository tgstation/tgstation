import {
  AnimatedNumber,
  Blink,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeAll, capitalizeFirst } from 'tgui-core/string';
import { useBackend, useSharedState } from '../../backend';
import { type BodyZone, BodyZoneSelector } from '../common/BodyZoneSelector';
import { extractSurgeryName } from './helpers';
import {
  ComputerTabs,
  damageTypes,
  type OperatingComputerData,
  type PatientData,
} from './types';

type PatientStateViewProps = {
  setTab: (tab: number) => void;
  setSearchText: (text: string) => void;
  pinnedOperations: string[];
  setPinnedOperations: (text: string[]) => void;
};
export const PatientStateView = (props: PatientStateViewProps) => {
  const { data } = useBackend<OperatingComputerData>();
  const { setTab, setSearchText, pinnedOperations, setPinnedOperations } =
    props;

  const { has_table, patient } = data;
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
  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <PatientStateMainStateView patient={patient} />
        </Stack.Item>
        <Stack.Item p={1}>
          <PatientStateSurgeryStateView
            patient={patient}
            target_zone={data.target_zone}
          />
        </Stack.Item>
        <Stack.Item grow>
          <PatientStateNextOperationsView
            pinnedOperations={pinnedOperations}
            setPinnedOperations={setPinnedOperations}
            setTab={setTab}
            setSearchText={setSearchText}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type PatientStateMainStateViewProps = {
  patient: PatientData;
};

const PatientStateMainStateView = (props: PatientStateMainStateViewProps) => {
  const { patient } = props;

  return (
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
  );
};

type PatientStateSurgeryStateViewProps = {
  patient: PatientData;
  target_zone: BodyZone;
};

const PatientStateSurgeryStateView = (
  props: PatientStateSurgeryStateViewProps,
) => {
  const { act, data } = useBackend<OperatingComputerData>();
  const { patient, target_zone } = props;

  return (
    <Stack>
      <Stack.Item>
        <BodyZoneSelector
          theme="slimecore"
          onClick={(zone) =>
            zone !== target_zone && act('change_zone', { new_zone: zone })
          }
          selectedZone={target_zone}
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
  );
};

type PatientStateNextOperationsViewProps = {
  pinnedOperations: string[];
  setPinnedOperations: (text: string[]) => void;
  setTab: (tab: number) => void;
  setSearchText: (text: string) => void;
};

const PatientStateNextOperationsView = (
  props: PatientStateNextOperationsViewProps,
) => {
  const { data } = useBackend<OperatingComputerData>();
  const { surgeries } = data;
  const { pinnedOperations, setPinnedOperations, setTab, setSearchText } =
    props;

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
    <Section
      title="Possible Operations"
      scrollable
      fill
      buttons={
        <Button
          icon="filter"
          tooltip="Filter by recommended tool. Right click to reset."
          tooltipPosition="top"
          width="100px"
          ellipsis
          selected={filterByTool !== allTools[0]}
          onClick={() =>
            setFilterByTool(
              allTools[(allTools.indexOf(filterByTool) + 1) % allTools.length],
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
            .filter(
              (operation) =>
                filterByTool === allTools[0] ||
                operation.tool_rec.includes(filterByTool),
            )
            .map((operation) => {
              const { name, tool } = extractSurgeryName(operation, false);
              return (
                <Stack.Item key={operation.name}>
                  <Button
                    fluid
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
                        {!!operation.show_in_list && (
                          <Stack.Item italic fontSize="0.9rem">
                            Right click opens operation info.
                          </Stack.Item>
                        )}
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
                      if (operation.show_in_list) {
                        setTab(ComputerTabs.OperationCatalog);
                        setSearchText(operation.name);
                      }
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
  );
};

import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { BodyZone, BodyZoneSelector } from './common/BodyZoneSelector';

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

export const OperatingComputer = (props) => {
  const { act } = useBackend();
  const [tab, setTab] = useSharedState('tab', 1);

  return (
    <Window width={350} height={470}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Patient State
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Surgery Procedures
          </Tabs.Tab>
          <Tabs.Tab onClick={() => act('open_experiments')}>
            Experiments
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <PatientStateView />}
        {tab === 2 && <SurgeryProceduresView />}
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
};

type Data = {
  has_table: BooleanLike;
  patient?: PatientData;
  target_zone: BodyZone;
  // static data
  surgeries: OperationData[];
  possible_next_operations: OperationData[];
};

const PatientStateView = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_table, patient, target_zone, possible_next_operations } = data;
  if (!has_table) {
    return <NoticeBox color="yellow">No Table Detected</NoticeBox>;
  }

  return (
    <Section title="Patient State">
      {patient ? (
        <Stack vertical>
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
                      : patient.blood_level >=
                          patient.standard_blood_level * 0.45
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
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <BodyZoneSelector
                  onClick={
                    // no limbs = don't allow changing zones
                    patient.has_limbs
                      ? (zone) => act('change_zone', { new_zone: zone })
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
          <Stack.Item>
            <Section title="Possible Operations">
              <Stack vertical>
                {possible_next_operations.length === 0 ? (
                  <Stack.Item>
                    <NoticeBox color="green">No operations available</NoticeBox>
                  </Stack.Item>
                ) : (
                  possible_next_operations.map((operation) => (
                    <Stack.Item key={operation.name}>
                      <Tooltip content={operation.desc}>
                        <Box
                          inline
                          style={{
                            borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                          }}
                        >
                          - {operation.name}
                        </Box>
                      </Tooltip>
                    </Stack.Item>
                  ))
                )}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      ) : (
        <NoticeBox color="red">No Patient Detected</NoticeBox>
      )}
    </Section>
  );
};

const SurgeryProceduresView = (props) => {
  const { act, data } = useBackend<Data>();
  const { surgeries } = data;
  return (
    <Section title="Advanced Surgery Procedures">
      <Button
        icon="download"
        content="Sync Research Database"
        onClick={() => act('sync')}
      />
      {surgeries.map((surgery) => (
        <Section title={surgery.name} key={surgery.name} level={2}>
          {surgery.desc}
        </Section>
      ))}
    </Section>
  );
};

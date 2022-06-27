import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Button, LabeledList, NoticeBox, ProgressBar, Section, Tabs } from '../components';
import { Window } from '../layouts';

const damageTypes = [
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

export const OperatingComputer = (props, context) => {
  const { act } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);

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

const PatientStateView = (props, context) => {
  const { act, data } = useBackend(context);
  const { table, procedures = [], patient = {} } = data;
  if (!table) {
    return <NoticeBox>No Table Detected</NoticeBox>;
  }
  return (
    <>
      <Section title="Patient State">
        {(patient && (
          <LabeledList>
            <LabeledList.Item label="State" color={patient.statstate}>
              {patient.stat}
            </LabeledList.Item>
            <LabeledList.Item label="Blood Type">
              {patient.blood_type}
            </LabeledList.Item>
            <LabeledList.Item label="Health">
              <ProgressBar
                value={patient.health}
                minValue={patient.minHealth}
                maxValue={patient.maxHealth}
                color={patient.health >= 0 ? 'good' : 'average'}>
                <AnimatedNumber value={patient.health} />
              </ProgressBar>
            </LabeledList.Item>
            {damageTypes.map((type) => (
              <LabeledList.Item key={type.type} label={type.label}>
                <ProgressBar
                  value={patient[type.type] / patient.maxHealth}
                  color="bad">
                  <AnimatedNumber value={patient[type.type]} />
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        )) ||
          'No Patient Detected'}
      </Section>
      {procedures.length === 0 && <Section>No Active Procedures</Section>}
      {procedures.map((procedure) => (
        <Section key={procedure.name} title={procedure.name}>
          <LabeledList>
            <LabeledList.Item label="Next Step">
              {procedure.next_step}
              {procedure.chems_needed && (
                <>
                  <br />
                  <br />
                  <b>Required Chemicals:</b>
                  <br />
                  {procedure.chems_needed}
                </>
              )}
            </LabeledList.Item>
            {!!data.alternative_step && (
              <LabeledList.Item label="Alternative Step">
                {procedure.alternative_step}
                {procedure.alt_chems_needed && (
                  <>
                    <br />
                    <br />
                    <b>Required Chemicals:</b>
                    <br />
                    {procedure.alt_chems_needed}
                  </>
                )}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      ))}
    </>
  );
};

const SurgeryProceduresView = (props, context) => {
  const { act, data } = useBackend(context);
  const { surgeries = [] } = data;
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

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Button, LabeledList, NoticeBox, ProgressBar, Section, Tabs } from '../components';

export const OperatingComputer = props => {
  const { act, data } = useBackend(props);
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
  const {
    table,
    surgeries = [],
    procedures = [],
    patient = {},
  } = data;
  return (
    <Tabs>
      <Tabs.Tab
        key="state"
        label="Patient State">
        {!table && (
          <NoticeBox>
            No Table Detected
          </NoticeBox>
        )}
        <Section>
          <Section
            title="Patient State"
            level={2}>
            {patient ? (
              <LabeledList>
                <LabeledList.Item
                  label="State"
                  color={patient.statstate}>
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
                    color={patient.health >= 0 ? 'good' : 'average'}
                    content={(
                      <AnimatedNumber value={patient.health} />
                    )} />
                </LabeledList.Item>
                {damageTypes.map(type => (
                  <LabeledList.Item key={type.type} label={type.label}>
                    <ProgressBar
                      value={patient[type.type] / patient.maxHealth}
                      color="bad"
                      content={(
                        <AnimatedNumber value={patient[type.type]} />
                      )} />
                  </LabeledList.Item>
                ))}
              </LabeledList>
            ) : (
              'No Patient Detected'
            )}
          </Section>
          <Section
            title="Initiated Procedures"
            level={2}>
            {procedures.length ? (
              procedures.map(procedure => (
                <Section
                  key={procedure.name}
                  title={procedure.name}
                  level={3}>
                  <LabeledList>
                    <LabeledList.Item label="Next Step">
                      {procedure.next_step}
                      {procedure.chems_needed && (
                        <Fragment>
                          <b>
                            Required Chemicals:
                          </b>
                          <br />
                          {procedure.chems_needed}
                        </Fragment>
                      )}
                    </LabeledList.Item>
                    {!!data.alternative_step && (
                      <LabeledList.Item label="Alternative Step">
                        {procedure.alternative_step}
                        {procedure.alt_chems_needed && (
                          <Fragment>
                            <b>
                             Required Chemicals:
                            </b>
                            <br />
                            {procedure.alt_chems_needed}
                          </Fragment>
                        )}
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
              ))
            ) : (
              'No Active Procedures'
            )}
          </Section>
        </Section>
      </Tabs.Tab>
      <Tabs.Tab
        key="procedures"
        label="Surgery Procedures">
        <Section title="Advanced Surgery Procedures">
          <Button
            icon="download"
            content="Sync Research Database"
            onClick={() => act('sync')} />
          {surgeries.map(surgery => (
            <Section
              title={surgery.name}
              key={surgery.name}
              level={2}>
              {surgery.desc}
            </Section>
          ))}
        </Section>
      </Tabs.Tab>
    </Tabs>
  );
};

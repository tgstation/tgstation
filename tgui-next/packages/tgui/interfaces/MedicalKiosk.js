import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const MedicalKiosk = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
 
  return (
    <Fragment>
      <Section title="Health Kiosk"
        textAlign="center"
        icon="procedures">
        <Box my={1} textAlign="center">
          Greetings Valued Employee. Please select your desired diagnosis. Diagnosis costs {data.kiosk_cost} credits.
          <Box mt={1} />
          <Box textAlign="center">
          Current patient targeted for scanning: {data.patient_name} |
          </Box>
          <Box my={1} mx={4} />
          <Button
            icon="procedures"
            disabled={!data.active_status_1}
            tooltip="Reads back exact values of your general health scan."
            onClick={() => act(ref, 'beginScan_1')}
            content="General Health Scan" />
          <Button
            icon="heartbeat"
            disabled={!data.active_status_2}
            tooltip="Provides information based on various non-obvious symptoms, like blood levels or disease status."
            onClick={() => act(ref, 'beginScan_2')}
            content="Symptom Based Checkup" />
          <Button
            tooltip="Resets the current scanning target, cancelling current scans."
            icon="sync"
            color="average"
            onClick={() => act(ref, 'clearTarget')}
            content="Reset Scanner" />
        </Box>
        <Box my={1} textAlign="center">
          <Button
            icon="radiation-alt"
            disabled={!data.active_status_3}
            tooltip="Provides information about brain trauma and radiation."
            onClick={() => act(ref, 'beginScan_3')}
            content="Neurological/Radiological Scan" />
          <Button
            icon="mortar-pestle"
            disabled={!data.active_status_4}
            tooltip="Provides a list of consumed chemicals, as well as potential side effects."
            onClick={() => act(ref, 'beginScan_4')}
            content="Chemical Analysis and Psychoactive Scan" />
        </Box>
      </Section>
      <Tabs>
        <Tabs.Tab key="tab_1" color="normal" label="View General Health Scan">
          {() => (
            <Box>
              {data.active_status_1 === 0 && (
                <Section title="Patient Health"
                  textAlign="center">
                  <LabeledList>
                    <LabeledList.Item
                      label="Total Health">
                      <ProgressBar
                        value={(data.patient_health)/100}>
                        <AnimatedNumber value={data.patient_health} />%
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Divider size={2} />
                    <LabeledList.Item
                      label="Brute Damage">
                      <ProgressBar
                        value={data.brute_health/100}
                        color="bad">
                        <AnimatedNumber value={data.brute_health} />
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Burn Damage">
                      <ProgressBar
                        value={data.burn_health/100}
                        color="bad">
                        <AnimatedNumber value={data.burn_health} />
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Oxygen Damage">
                      <ProgressBar
                        value={data.suffocation_health/100}
                        color="bad">
                        <AnimatedNumber value={data.suffocation_health} />
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Toxin Damage">
                      <ProgressBar
                        value={data.toxin_health/100}
                        color="bad">
                        <AnimatedNumber value={data.toxin_health} />
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              )}
            </Box>
          )}
        </Tabs.Tab>
        <Tabs.Tab key="tab_2" color="normal" label="View Symptom Based Checkup">
          {() => (
            <Box>
              {data.active_status_2 === 0 && (
                <Section title="Symptom Based Checkup"
                  textAlign="center">
                  <LabeledList>
                    <LabeledList.Item
                      label="Patient Status"
                      color="good">
                      {data.patient_status}
                    </LabeledList.Item>
                    <LabeledList.Divider size={1} />
                    <LabeledList.Item
                      label="Disease Status">
                      {data.patient_illness}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Disease information">
                      {data.illness_info}
                    </LabeledList.Item>
                    <LabeledList.Divider size={1} />
                    <LabeledList.Item
                      label="Blood Levels">
                      {data.bleed_status}
                      <LabeledList.Divider size={1} />
                      <ProgressBar
                        value={data.blood_levels/100}
                        color="bad">                  
                        <AnimatedNumber value={data.blood_levels} />
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Blood Information">
                      {data.blood_status}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              )}
            </Box>
          )}
        </Tabs.Tab>
        <Tabs.Tab key="tab_3" color="normal" label="View Neurological/Radiological Scan">
          {() => (
            <Box>
              {data.active_status_3 === 0 && (
                <Section title="Patient Neurological and Radiological Health "
                  textAlign="center">
                  <LabeledList.Item
                    label="Cellular Damage">
                    <ProgressBar
                      value={data.clone_health/100}
                      color="good">
                      <AnimatedNumber value={data.clone_health} />
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Brain Damage">
                    <ProgressBar
                      value={data.brain_damage/100}
                      color="good">
                      <AnimatedNumber value={data.brain_damage} />
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Brain Status"
                    color="health-0">
                    {data.brain_health}
                  </LabeledList.Item>

                  <LabeledList.Item
                    label="Radiation Status">
                    {data.rad_status}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Irradiation Percentage">
                    {data.rad_value}%
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Brain Trauma Status">
                    {data.trauma_status}
                  </LabeledList.Item>
                </Section>
              )}
            </Box>
          )}
        </Tabs.Tab>
        <Tabs.Tab key="tab_4" color="normal" label="View Chemical Analysis and Psychoactive Scan">
          {() => (
            <Box>
              {data.active_status_4 === 0 && (
                <Section title="Chemical and Psychoactive Analysis"
                  textAlign="center">
                  <LabeledList.Item label="Chemical Contents">
                    {data.are_chems_present ? (
                      data.chemical_list.length ? (
                        data.chemical_list.map(specificChem => (
                          <Box
                            key={specificChem.id}
                            color="good" >
                            {specificChem.volume} units of {specificChem.name}
                          </Box>
                        ))
                      ) : (
                        <Box content="No reagents detected." />
                      )
                    ) : (
                      <Box color="average" content="No reagents detected." /> 
                    )}
				
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Overdose Status"
                    color="bad">
                    {data.are_overdoses_present ? (
                      data.overdose_status.length ? (
                        data.overdose_status.map(specificOD => (
                          <Box
                            key={specificOD.id}>
                    Overdosing on {specificOD.name}
                          </Box>
                        ))
                      ) : (
                        <Box content="No reagents detected." />
                      )
                    ) : (
                      <Box color="good" content="Patient is not overdosing." /> 
                    )} 
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Addiction Status"
                    color="bad">
                    {data.are_addictions_present ? (
                      data.addiction_status.length ? (
                        data.addiction_status.map(specificAddict => (
                          <Box
                            key={specificAddict.id}>
                    Addicted to {specificAddict.name}
                          </Box>
                        ))
                      ) : (
                        <Box content="Patient has no addictions." />
                      )
                    ) : (
                      <Box color="good" content="Patient has no addictions detected." /> 
                    )}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Psychoactive Status">
                    {data.hallucinating_status}
                  </LabeledList.Item>
                </Section>
              )}
            </Box>
          )}
        </Tabs.Tab>
      </Tabs>
    </Fragment>
  );
};

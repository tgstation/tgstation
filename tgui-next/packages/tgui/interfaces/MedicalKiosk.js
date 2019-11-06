import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section } from '../components';

export const MedicalKiosk = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
 
  return (
    <Fragment>
      <Section title="Health Kiosk"
<<<<<<< HEAD
        textAlign="center">
        <Box as="span" m={1} textAlign="center">
          Greetings Valued Employee. Please select your desired treatment type from the options below.
          <Button
            icon="procedures"
            disabled={data.active_status}
            onClick={() => act(ref, 'beginScan')}
            content="General Health Scan" />
          <Button
            icon="heartbeat"
            disabled={data.active_status}
            onClick={() => act(ref, 'beginScan')}
=======
        textAlign="center"
        icon="procedures">
        <Box m={1} textAlign="center">
          Greetings Valued Employee. Please select your desired diagnosis. Diagnosis costs {data.kiosk_cost} credits.
          <Box mt={2} />
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
>>>>>>> Chemical readout is done and looks up to par, shows overdosing, addictions, chems and units.
            content="Symptom Based Checkup" />
          <Button
            icon="radiation-alt"
<<<<<<< HEAD
            disabled={data.active_status}
            onClick={() => act(ref, 'beginScan')}
            content="Neurological/Radiological Scan" />
=======
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
>>>>>>> Chemical readout is done and looks up to par, shows overdosing, addictions, chems and units.
        </Box>
      </Section>
      <Section title="Patient Health"
        textAlign="center">
        <LabeledList>
          <LabeledList.Item
            label="Total Health">
            <ProgressBar
              value={data.patient_health/100}
              color="grey">
              <AnimatedNumber value={data.patient_health} />%
            </ProgressBar>
            <LabeledList.Divider size={2} />
          </LabeledList.Item>
          <LabeledList.Item
            label="Brute Health">
            <ProgressBar
              value={data.brute_health/100}
              color="bad">
              <AnimatedNumber value={data.brute_health} />
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item
            label="Burn Health">
            <ProgressBar
              value={data.burn_health/100}
              color="bad">
              <AnimatedNumber value={data.burn_health} />
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item
            label="Oxygen Health">
            <ProgressBar
              value={data.suffocation_health/100}
              color="bad">
              <AnimatedNumber value={data.suffocation_health} />
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item
            label="Toxin Health">
            <ProgressBar
              value={data.toxin_health/100}
              color="bad">
              <AnimatedNumber value={data.toxin_health} />
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Symptom Based Checkup"
        textAlign="center">
        <LabeledList>
          <LabeledList.Item
            label="Patient Status"
            color="health-0">
            {data.patient_status}
            <LabeledList.Divider size={1} />
          </LabeledList.Item>
          <LabeledList.Item
            label="Disease Status">
            {data.patient_illness}
          </LabeledList.Item>
<<<<<<< HEAD
          <LabeledList.Item
            label="Disease information">
            {data.illness_info}
          </LabeledList.Item>
          <LabeledList.Item
            label="Blood Levels">
            {data.bleed_status}
            <LabeledList.Divider size={1} />
            <ProgressBar
              value={data.blood_levels/100}
              color="bad">                  
              <AnimatedNumber value={data.blood_levels} />
            </ProgressBar>
=======
        </Section>
      )}
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
            {data.overdose_status} 
          </LabeledList.Item>
          <LabeledList.Item
            label="Addiction Status"
            color="good">
            {data.addiction_status}
>>>>>>> Chemical readout is done and looks up to par, shows overdosing, addictions, chems and units.
          </LabeledList.Item>
          <LabeledList.Item
            label="Blood Information">
            {data.blood_status}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Patient Neurological and Radiological Health"
        textAlign="center">
        <LabeledList.Item
          label="Cellular Health">
          <ProgressBar
            value={data.clone_health/100}
            color="good">
            <AnimatedNumber value={data.clone_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Brain Health">
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
          <LabeledList.Divider size={1} />
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
    </Fragment>
  ); };

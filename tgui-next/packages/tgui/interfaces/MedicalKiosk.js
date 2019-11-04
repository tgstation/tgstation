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
            content="Symptom Based Checkup" />
          <Button
            icon="radiation-alt"
            disabled={data.active_status}
            onClick={() => act(ref, 'beginScan')}
            content="Neurological/Radiological Scan" />
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

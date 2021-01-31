import { multiline } from 'common/string';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Icon, LabeledList, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

export const MedicalKiosk = (props, context) => {
  const { act, data } = useBackend(context);
  const [scanIndex] = useSharedState(context, 'scanIndex');
  const {
    active_status_1,
    active_status_2,
    active_status_3,
    active_status_4,
  } = data;
  return (
    <Window
      width={575}
      height={420}
      resizable>
      <Window.Content scrollable>
        <Flex mb={1}>
          <Flex.Item mr={1}>
            <Section minHeight="100%">
              <MedicalKioskScanButton
                index={1}
                icon="procedures"
                name="General Health Scan"
                description={multiline`
                  Reads back exact values of your general health scan.
                `} />
              <MedicalKioskScanButton
                index={2}
                icon="heartbeat"
                name="Symptom Based Checkup"
                description={multiline`
                  Provides information based on various non-obvious symptoms,
                  like blood levels or disease status.
                `} />
              <MedicalKioskScanButton
                index={3}
                icon="radiation-alt"
                name="Neurological/Radiological Scan"
                description={multiline`
                  Provides information about brain trauma and radiation.
                `} />
              <MedicalKioskScanButton
                index={4}
                icon="mortar-pestle"
                name="Chemical and Psychoactive Scan"
                description={multiline`
                  Provides a list of consumed chemicals, as well as potential
                  side effects.
                `} />
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <MedicalKioskInstructions />
          </Flex.Item>
        </Flex>
        {!!active_status_1 && scanIndex === 1 && (
          <MedicalKioskScanResults1 />
        )}
        {!!active_status_2 && scanIndex === 2 && (
          <MedicalKioskScanResults2 />
        )}
        {!!active_status_3 && scanIndex === 3 && (
          <MedicalKioskScanResults3 />
        )}
        {!!active_status_4 && scanIndex === 4 && (
          <MedicalKioskScanResults4 />
        )}
      </Window.Content>
    </Window>
  );
};

const MedicalKioskScanButton = (props, context) => {
  const {
    index,
    name,
    description,
    icon,
  } = props;
  const { act, data } = useBackend(context);
  const [scanIndex, setScanIndex] = useSharedState(context, 'scanIndex');
  const paid = data[`active_status_${index}`];
  return (
    <Stack align="baseline">
      <Stack.Item width="16px" textAlign="center">
        <Icon
          name={paid ? 'check' : 'dollar-sign'}
          color={paid ? 'green' : 'grey'} />
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          icon={icon}
          selected={paid && scanIndex === index}
          tooltip={description}
          tooltipPosition="right"
          content={name}
          onClick={() => {
            if (!paid) {
              act(`beginScan_${index}`);
            }
            setScanIndex(index);
          }} />
      </Stack.Item>
    </Stack>
  );
};

const MedicalKioskInstructions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    kiosk_cost,
    patient_name,
  } = data;
  return (
    <Section minHeight="100%">
      <Box italic>
        Greetings Valued Employee! Please select a desired automatic
        health check procedure. Diagnosis costs <b>{kiosk_cost} credits.</b>
      </Box>
      <Box mt={1}>
        <Box inline color="label" mr={1}>
          Patient:
        </Box>
        {patient_name}
      </Box>
      <Button
        mt={1}
        tooltip={multiline`
          Resets the current scanning target, cancelling current scans.
        `}
        icon="sync"
        color="average"
        onClick={() => act('clearTarget')}
        content="Reset Scanner" />
    </Section>
  );
};

const MedicalKioskScanResults1 = (props, context) => {
  const { data } = useBackend(context);
  const {
    patient_health,
    brute_health,
    burn_health,
    suffocation_health,
    toxin_health,
  } = data;
  return (
    <Section title="Patient Health">
      <LabeledList>
        <LabeledList.Item
          label="Total Health">
          <ProgressBar
            value={patient_health / 100}>
            <AnimatedNumber value={patient_health} />%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item
          label="Brute Damage">
          <ProgressBar
            value={brute_health / 100}
            color="bad">
            <AnimatedNumber value={brute_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Burn Damage">
          <ProgressBar
            value={burn_health / 100}
            color="bad">
            <AnimatedNumber value={burn_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Oxygen Damage">
          <ProgressBar
            value={suffocation_health / 100}
            color="bad">
            <AnimatedNumber value={suffocation_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Toxin Damage">
          <ProgressBar
            value={toxin_health / 100}
            color="bad">
            <AnimatedNumber value={toxin_health} />
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults2 = (props, context) => {
  const { data } = useBackend(context);
  const {
    patient_status,
    patient_illness,
    illness_info,
    bleed_status,
    blood_levels,
    blood_status,
  } = data;
  return (
    <Section title="Symptom Based Checkup">
      <LabeledList>
        <LabeledList.Item
          label="Patient Status"
          color="good">
          {patient_status}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item
          label="Disease Status">
          {patient_illness}
        </LabeledList.Item>
        <LabeledList.Item
          label="Disease information">
          {illness_info}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item
          label="Blood Levels">
          <ProgressBar
            value={blood_levels / 100}
            color="bad">
            <AnimatedNumber value={blood_levels} />
          </ProgressBar>
          <Box mt={1} color="label">
            {bleed_status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item
          label="Blood Information">
          {blood_status}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults3 = (props, context) => {
  const { data } = useBackend(context);
  const {
    clone_health,
    brain_damage,
    brain_health,
    rad_contamination_status,
    rad_contamination_value,
    rad_sickness_status,
    rad_sickness_value,
    trauma_status,
  } = data;
  return (
    <Section title="Patient Neurological and Radiological Health">
      <LabeledList>
        <LabeledList.Item
          label="Cellular Damage">
          <ProgressBar
            value={clone_health / 100}
            color="good">
            <AnimatedNumber value={clone_health} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item
          label="Brain Damage">
          <ProgressBar
            value={brain_damage / 100}
            color="good">
            <AnimatedNumber value={brain_damage} />
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Brain Status"
          color="health-0">
          {brain_health}
        </LabeledList.Item>
        <LabeledList.Item
          label="Brain Trauma Status">
          {trauma_status}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item
          label="Radiation Sickness Status">
          {rad_sickness_status}
        </LabeledList.Item>
        <LabeledList.Item
          label="Radiation Sickness Percentage">
          {rad_sickness_value}%
        </LabeledList.Item>
        <LabeledList.Item
          label="Radiation Contamination Status">
          {rad_contamination_status}
        </LabeledList.Item>
        <LabeledList.Item
          label="Radiation Contamination Percentage">
          {rad_contamination_value}%
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MedicalKioskScanResults4 = (props, context) => {
  const { data } = useBackend(context);
  const {
    chemical_list = [],
    overdose_list = [],
    addict_list = [],
    hallucinating_status,
  } = data;
  return (
    <Section title="Chemical and Psychoactive Analysis">
      <LabeledList>
        <LabeledList.Item
          label="Chemical Contents">
          {chemical_list.length === 0 && (
            <Box color="average">
              No reagents detected.
            </Box>
          )}
          {chemical_list.map(chem => (
            <Box
              key={chem.id}
              color="good">
              {chem.volume} units of {chem.name}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item
          label="Overdose Status"
          color="bad">
          {overdose_list.length === 0 && (
            <Box color="good">
              Patient is not overdosing.
            </Box>
          )}
          {overdose_list.map(chem => (
            <Box key={chem.id}>
              Overdosing on {chem.name}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item
          label="Addiction Status"
          color="bad">
          {addict_list.length === 0 && (
            <Box color="good">
              Patient has no addictions.
            </Box>
          )}
          {addict_list.map(chem => (
            <Box key={chem.id}>
              Addicted to {chem.name}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item
          label="Psychoactive Status">
          {hallucinating_status}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

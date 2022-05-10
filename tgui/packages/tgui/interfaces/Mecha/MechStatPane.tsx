import { useBackend } from '../../backend';
import { Stack, Button, Section, Box, ProgressBar, LabeledList } from '../../components';
import { KelvinZeroCelcius, OperatorData } from './data';
import { toFixed } from 'common/math';

export const MechStatPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const {
    name,
    integrity,
    airtank_present,
    weapons_safety,
    air_source,
    cabin_pressure,
    cabin_dangerous_highpressure,
    cabin_temp,
    mecha_flags,
    mechflag_keys,
    port_connected,
  } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={name}
          buttons={(
            <Button onClick={() => act('changename')}>
              Rename
            </Button>
          )} />
      </Stack.Item>
      <Stack.Item>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Integrity">
              <ProgressBar
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.25, 0.5],
                  bad: [-Infinity, 0.25],
                }}
                value={integrity} />
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <PowerBar />
            </LabeledList.Item>
            <LabeledList.Item label="Safety">
              <Button color={weapons_safety ? "red" : ""} onClick={() => act('toggle_safety')}>
                {weapons_safety ? "Dis" : "En"}able
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Enviromental Data">
          <LabeledList>
            <LabeledList.Item label="Air Source">
              <Button 
                disabled={!airtank_present}
                onClick={() => act('toggle_airsource')}>
                {air_source}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Cabin pressure">
              <Box color={cabin_pressure>cabin_dangerous_highpressure?"red":null}>
                {cabin_pressure} kPa
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Cabin temperature">
              <Box>
                {GetTempFormat(cabin_temp)}
              </Box>
            </LabeledList.Item>
            <EnviromentalAir />
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="DNA lock">
          <DNABody />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Maintenance">
          <LabeledList>
            <LabeledList.Item label="Maintenance mode">
              <Button onClick={() => act('toggle_maintenance')} selected={mecha_flags & mechflag_keys["ADDING_MAINT_ACCESS_POSSIBLE"]}>
                {(mecha_flags & mechflag_keys["ADDING_MAINT_ACCESS_POSSIBLE"]) ? "En" : "Dis"}abled
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="ID reader panel">
              <Button onClick={() => act('toggle_id_panel')} selected={mecha_flags & mechflag_keys["ADDING_ACCESS_POSSIBLE"]}>
                {(mecha_flags & mechflag_keys["ADDING_ACCESS_POSSIBLE"]) ? "En" : "Dis"}abled
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Port connection">
              <Button onClick={() => act('toggle_port')} selected={port_connected}>
                {port_connected ? "C":"Disc"}onnected
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const GetTempFormat = (temp) => {
  return toFixed(temp, 1) +"°K\n"+ toFixed(temp-KelvinZeroCelcius, 1) + "°C";
};


const EnviromentalAir = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const {
    airtank_pressure,
    airtank_temp,
  } = data;
  if (airtank_temp === null) {
    return (<Box>No air tank detected</Box>);
  } else {
    return (
      <>
        <LabeledList.Item label="Air tank Pressure">
          {airtank_pressure} kPa
        </LabeledList.Item>
        <LabeledList.Item label="Air tank temperature">
          {GetTempFormat(airtank_temp)}
        </LabeledList.Item>
      </>
    );
  }
};

const DNABody = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const {
    dna_lock,
  } = data;
  if (dna_lock === null) {
    return (
      <LabeledList>
        <LabeledList.Item label="DNA Enzymes">
          <Button onClick={() => act('dna_lock')} icon={'syringe'}>
            Set new DNA key
          </Button>
        </LabeledList.Item>
      </LabeledList>
    );
  } else {
    return (
      <LabeledList>
        <LabeledList.Item label="DNA Enzymes">
          <Button onClick={() => act('dna_lock')} icon={'syringe'}>
            Set new DNA key
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Enzymes">
          <Button onClick={() => act('view_dna')} icon={'list'}>
            View enzyme list
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Reset DNA">
          <Button onClick={() => act('reset_dna')} icon={'ban'}>
            Reset DNA lock
          </Button>
        </LabeledList.Item>
      </LabeledList>
    );
  }
};

const PowerBar = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const {
    power_level,
    power_max,
  } = data;
  if (power_max === null) {
    return (<Box content={"No Power cell installed!"} />);
  } else {
    return (
      <ProgressBar
        ranges={{
          good: [0.75*power_max, Infinity],
          average: [0.25*power_max, 0.75*power_max],
          bad: [-Infinity, 0.25*power_max],
        }}
        maxValue={power_max}
        value={power_level} />
    );
  }
};

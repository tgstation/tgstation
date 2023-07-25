import { useBackend } from '../../backend';
import { ByondUi, Stack, Button, Section, Box, ProgressBar, LabeledList } from '../../components';
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
    mech_view,
  } = data;
  return (
    <Section
      fill
      title={name}
      buttons={
        <Button
          icon="edit"
          tooltip="Rename"
          tooltipPosition="left"
          onClick={() => act('changename')}
        />
      }>
      <Stack fill vertical>
        <Stack.Item>
          <ByondUi
            height="170px"
            params={{
              id: mech_view,
              zoom: 5,
              type: 'map',
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Integrity">
              <ProgressBar
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.25, 0.5],
                  bad: [-Infinity, 0.25],
                }}
                value={integrity}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <PowerBar />
            </LabeledList.Item>
            <LabeledList.Item label="DNA Lock">
              <DNABody />
            </LabeledList.Item>
            <LabeledList.Item label="ID reader">
              <Button
                onClick={() => act('toggle_id_panel')}
                selected={
                  mecha_flags & mechflag_keys['ADDING_ACCESS_POSSIBLE']
                }>
                {mecha_flags & mechflag_keys['ADDING_ACCESS_POSSIBLE']
                  ? 'En'
                  : 'Dis'}
                abled
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Maintenance">
              <Button
                onClick={() => act('toggle_maintenance')}
                selected={
                  mecha_flags & mechflag_keys['ADDING_MAINT_ACCESS_POSSIBLE']
                }>
                {mecha_flags & mechflag_keys['ADDING_MAINT_ACCESS_POSSIBLE']
                  ? 'En'
                  : 'Dis'}
                abled
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const GetTempFormat = (temp) => {
  return (
    toFixed(temp, 1) + '°K\n' + toFixed(temp - KelvinZeroCelcius, 1) + '°C'
  );
};

const EnviromentalAir = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { airtank_pressure, airtank_temp } = data;
  if (airtank_temp === null) {
    return <Box>No air tank detected</Box>;
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
  const { dna_lock } = data;
  return (
    <Box>
      <Button
        onClick={() => act('dna_lock')}
        icon={'syringe'}
        tooltip="Set new DNA key"
        tooltipPosition="top"
      />
      <Button
        onClick={() => act('view_dna')}
        icon={'list'}
        tooltip="View enzyme list"
        tooltipPosition="top"
        disabled={!dna_lock}
      />
      <Button
        onClick={() => act('reset_dna')}
        icon={'ban'}
        tooltip="Reset DNA lock"
        tooltipPosition="top"
        disabled={!dna_lock}
      />
    </Box>
  );
};

const PowerBar = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { power_level, power_max } = data;
  if (power_max === null) {
    return <Box content={'No Power cell installed!'} />;
  } else {
    return (
      <ProgressBar
        ranges={{
          good: [0.75 * power_max, Infinity],
          average: [0.25 * power_max, 0.75 * power_max],
          bad: [-Infinity, 0.25 * power_max],
        }}
        maxValue={power_max}
        value={power_level}
      />
    );
  }
};

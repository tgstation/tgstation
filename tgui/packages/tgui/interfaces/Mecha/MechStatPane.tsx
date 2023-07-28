import { useBackend } from '../../backend';
import { ByondUi, Stack, Button, Section, Box, ProgressBar, LabeledList } from '../../components';
import { KelvinZeroCelcius, OperatorData } from './data';
import { toFixed } from 'common/math';

export const MechStatPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const {
    name,
    integrity,
    mecha_flags,
    mechflag_keys,
    mech_view,
    enclosed,
    cabin_sealed,
    cabin_temp,
    cabin_pressure,
    cabin_pressure_warning_min,
    cabin_pressure_hazard_min,
    cabin_pressure_warning_max,
    cabin_pressure_hazard_max,
    cabin_temp_warning_min,
    cabin_temp_hazard_min,
    cabin_temp_warning_max,
    cabin_temp_hazard_max,
  } = data;
  const temp_warning =
    cabin_temp < cabin_temp_warning_min || cabin_temp > cabin_temp_warning_max;
  const temp_hazard =
    cabin_temp < cabin_temp_hazard_min || cabin_temp > cabin_temp_hazard_max;
  const pressure_warning =
    cabin_pressure < cabin_pressure_warning_min ||
    cabin_pressure > cabin_pressure_warning_max;
  const pressure_hazard =
    cabin_pressure < cabin_pressure_hazard_min ||
    cabin_pressure > cabin_pressure_hazard_max;
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
            <LabeledList.Item
              label="Cabin"
              buttons={
                !!cabin_sealed && (
                  <>
                    <Button
                      color={
                        temp_hazard
                          ? 'danger'
                          : temp_warning
                            ? 'average'
                            : 'transparent'
                      }
                      icon="temperature-low"
                      tooltipPosition="top"
                      tooltip={`Air temperature: ${cabin_temp}°C`}
                    />
                    <Button
                      color={
                        pressure_hazard
                          ? 'danger'
                          : pressure_warning
                            ? 'average'
                            : 'transparent'
                      }
                      icon="gauge-high"
                      tooltipPosition="top"
                      tooltip={`Air pressure: ${cabin_pressure}kPa`}
                    />
                  </>
                )
              }>
              <Button
                icon={cabin_sealed ? 'mask-ventilator' : 'wind'}
                content={cabin_sealed ? 'Airtight' : 'Open'}
                disabled={!enclosed}
                onClick={() => act('toggle_cabin_seal')}
                selected={cabin_sealed}
              />
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

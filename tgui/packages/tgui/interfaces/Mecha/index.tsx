import { Window } from '../../layouts';
import { useBackend, useLocalState } from '../../backend';
import { ByondUi, Stack, Button, Section, Box, ProgressBar, LabeledList } from '../../components';
import { ModulesPane } from './ModulesPane';
import { AlertPane } from './AlertPane';
import { AccessConfig } from '../common/AccessConfig';
import { MainData } from './data';

export const Mecha = (props, context) => {
  const { data } = useBackend<MainData>(context);
  return (
    <Window theme={data.ui_theme} width={800} height={550}>
      <Window.Content>
        <Content />
      </Window.Content>
    </Window>
  );
};

export const Content = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const [edit_access, editAccess] = useLocalState(
    context,
    'edit_access',
    false
  );
  const {
    name,
    mecha_flags,
    mechflag_keys,
    mech_view,
    one_access,
    regions,
    accesses,
  } = data;
  const id_lock = mecha_flags & mechflag_keys['ID_LOCK_ON'];
  return (
    <Stack fill>
      <Stack.Item grow={1}>
        <Stack vertical fill>
          <Stack.Item grow overflow="hidden">
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
                    <IntegrityBar />
                    <PowerBar />
                    <CabinSeal />
                    <DNALock />
                    <LabeledList.Item label="ID Lock">
                      <Button
                        icon={id_lock ? 'lock' : 'lock-open'}
                        content={id_lock ? 'Enabled' : 'Disabled'}
                        tooltipPosition="top"
                        onClick={() => {
                          editAccess(false);
                          act('toggle_id_lock');
                        }}
                        selected={id_lock}
                      />
                      {!!id_lock && (
                        <>
                          <Button
                            tooltip="Edit Access"
                            tooltipPosition="top"
                            icon="id-card-o"
                            onClick={() => editAccess(!edit_access)}
                            selected={edit_access}
                          />
                          <Button
                            tooltip={one_access ? 'Require Any' : 'Require All'}
                            tooltipPosition="top"
                            icon={one_access ? 'check' : 'check-double'}
                            onClick={() => act('one_access')}
                          />
                        </>
                      )}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <AlertPane />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow={2}>
        {edit_access ? (
          <AccessConfig
            accesses={regions}
            selectedList={accesses}
            accessMod={(ref) =>
              act('set', {
                access: ref,
              })
            }
            grantAll={() => act('grant_all')}
            denyAll={() => act('clear_all')}
            grantDep={(ref) =>
              act('grant_region', {
                region: ref,
              })
            }
            denyDep={(ref) =>
              act('deny_region', {
                region: ref,
              })
            }
          />
        ) : (
          <ModulesPane />
        )}
      </Stack.Item>
    </Stack>
  );
};

const PowerBar = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const { power_level, power_max } = data;
  return (
    <LabeledList.Item label="Power">
      {power_max === null ? (
        <Box italic content={'No power cell installed.'} />
      ) : (
        <ProgressBar
          ranges={{
            good: [0.75 * power_max, Infinity],
            average: [0.25 * power_max, 0.75 * power_max],
            bad: [-Infinity, 0.25 * power_max],
          }}
          maxValue={power_max}
          value={power_level}
        />
      )}
    </LabeledList.Item>
  );
};

const IntegrityBar = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const { integrity, scanmod_rating } = data;
  return (
    <LabeledList.Item label="Integrity">
      {!scanmod_rating ? (
        <Box italic>Unknown</Box>
      ) : (
        <ProgressBar
          ranges={{
            good: [0.5, Infinity],
            average: [0.25, 0.5],
            bad: [-Infinity, 0.25],
          }}
          value={integrity}
        />
      )}
    </LabeledList.Item>
  );
};

const CabinSeal = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const {
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
    <LabeledList.Item
      label="Cabin Air"
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
              tooltip={`Air pressure: ${cabin_pressure} kPa`}
            />
          </>
        )
      }>
      <Button
        icon={cabin_sealed ? 'mask-ventilator' : 'wind'}
        content={cabin_sealed ? 'Sealed' : 'Exposed'}
        disabled={!enclosed}
        onClick={() => act('toggle_cabin_seal')}
        selected={cabin_sealed}
      />
    </LabeledList.Item>
  );
};

const DNALock = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const { dna_lock } = data;
  return (
    <LabeledList.Item label="DNA Lock">
      <Button
        onClick={() => act('dna_lock')}
        icon="syringe"
        content={dna_lock ? 'Enabled' : 'Unset'}
        tooltip="Set new DNA key"
        selected={!!dna_lock}
        tooltipPosition="top"
      />
      {!!dna_lock && (
        <>
          <Button
            icon="key"
            tooltip={`Key enzyme: ${dna_lock}`}
            tooltipPosition="top"
            disabled={!dna_lock}
          />
          <Button
            onClick={() => act('reset_dna')}
            icon="ban"
            tooltip="Reset DNA lock"
            tooltipPosition="top"
            disabled={!dna_lock}
          />
        </>
      )}
    </LabeledList.Item>
  );
};

import { Window } from '../../layouts';
import { useBackend, useLocalState } from '../../backend';
import { ByondUi, Stack, Button, Section, ProgressBar, LabeledList } from '../../components';
import { formatSiUnit } from '../../format';
import { ModulesPane } from './ModulesPane';
import { AlertPane } from './AlertPane';
import { AccessConfig } from '../common/AccessConfig';
import { MainData } from './data';

export const Mecha = (props, context) => {
  const { data } = useBackend<MainData>(context);
  return (
    <Window theme={data.ui_theme} width={800} height={560}>
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
                    <LightsBar />
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
      <ProgressBar
        value={power_max ? power_level / power_max : 0}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          'text-shadow': '1px 1px 0 black',
        }}>
        {power_max === null
          ? 'Power cell missing'
          : power_level === 1e31
            ? 'Infinite'
            : `${formatSiUnit(power_level * 1000, 0, 'J')} of ${formatSiUnit(
              power_max * 1000,
              0,
              'J'
            )}`}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const IntegrityBar = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const { integrity, integrity_max, scanmod_rating } = data;
  return (
    <LabeledList.Item label="Integrity">
      <ProgressBar
        value={scanmod_rating ? integrity / integrity_max : 0}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          'text-shadow': '1px 1px 0 black',
        }}>
        {!scanmod_rating ? 'Unknown' : `${integrity} of ${integrity_max}`}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const LightsBar = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const { power_level, power_max, mecha_flags, mechflag_keys } = data;
  const has_lights = mecha_flags & mechflag_keys['HAS_LIGHTS'];
  const lights_on = mecha_flags & mechflag_keys['LIGHTS_ON'];
  return (
    <LabeledList.Item label="Lights">
      <Button
        icon="lightbulb"
        content={lights_on ? 'On' : 'Off'}
        selected={lights_on}
        disabled={!has_lights || !power_max || !power_level}
        onClick={() => act('toggle_lights')}
      />
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

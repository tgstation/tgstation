import { useLocalState, useBackend } from '../../backend';
import { NumberInput, ProgressBar, Box, Button, Section, Stack, LabeledList, Divider, NoticeBox } from '../../components';
import { OperatorData, MechModule } from './data';
import { classes } from 'common/react';
import { toFixed } from 'common/math';
import { formatPower } from '../../format';

const moduleIcon = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'hand';
    case 'mecha_r_arm':
      return 'hand';
    case 'mecha_utility':
      return 'screwdriver-wrench';
    case 'mecha_power':
      return 'bolt';
    case 'mecha_armor':
      return 'shield-halved';
    default:
      return 'screwdriver-wrench';
  }
};

const emptyModuleText = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'Left Arm Slot';
    case 'mecha_r_arm':
      return 'Right Arm Slot';
    case 'mecha_utility':
      return 'Utility Module Slot';
    case 'mecha_power':
      return 'Power Module Slot';
    case 'mecha_armor':
      return 'Armor Module Slot';
    default:
      return 'Module Slot';
  }
};

export const ModulesPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const [selectedModule, setSelectedModule] = useLocalState(
    context,
    'selectedModule',
    0
  );
  const { mech_electronics, airtank_present, modules } = data;
  return (
    <Section title="Equipment" fill>
      <Stack>
        <Stack.Item>
          {modules.map((module, i) =>
            !module.ref ? (
              <Button
                p={1}
                fluid
                icon={moduleIcon(module.type)}
                key={i}
                color="transparent">
                {emptyModuleText(module.type)}
              </Button>
            ) : (
              <Button
                p={1}
                fluid
                icon={moduleIcon(module.type)}
                key={i}
                selected={i === selectedModule}
                onClick={() => setSelectedModule(i)}
                style={{ 'text-transform': 'capitalize' }}>
                {module.name}
              </Button>
            )
          )}
        </Stack.Item>
        <Stack.Item grow pl={1}>
          {!!modules[selectedModule] && (
            <ModuleDetails module={modules[selectedModule]} />
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const ModuleDetails = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { name, desc, icon, detachable, ref, snowflake } = props.module;
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Box className={classes(['mecha_equipment32x32', icon])} />
          </Stack.Item>
          <Stack.Item grow>
            <h2 style={{ 'text-transform': 'capitalize' }}>{name}</h2>
          </Stack.Item>
          {!!detachable && (
            <Stack.Item>
              <Button
                icon="eject"
                tooltip="Detach"
                fontSize={1.5}
                onClick={() =>
                  act('equip_act', {
                    ref: ref,
                    gear_action: 'detach',
                  })
                }
              />
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack.Item>{desc}</Stack.Item>
      <Divider />
      <Stack.Item>
        {!!snowflake && <ModuleDetailsExtra module={props.module} />}
      </Stack.Item>
    </Stack>
  );
};

const MECHA_SNOWFLAKE_ID_SLEEPER = 'sleeper_snowflake';
const MECHA_SNOWFLAKE_ID_SYRINGE = 'syringe_snowflake';
const MECHA_SNOWFLAKE_ID_MODE = 'mode_snowflake';
const MECHA_SNOWFLAKE_ID_EXTINGUISHER = 'extinguisher_snowflake';
const MECHA_SNOWFLAKE_ID_EJECTOR = 'ejector_snowflake';
const MECHA_SNOWFLAKE_ID_OREBOX_MANAGER = 'orebox_manager_snowflake';
const MECHA_SNOWFLAKE_ID_RADIO = 'radio_snowflake';
const MECHA_SNOWFLAKE_ID_AIR_TANK = 'air_tank_snowflake';
const MECHA_SNOWFLAKE_ID_WEAPON = 'weapon_snowflake';
const MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC = 'ballistic_weapon_snowflake';

export const ModuleDetailsExtra = (props: { module: MechModule }, context) => {
  const module = props.module;
  switch (module.snowflake.snowflake_id) {
    case MECHA_SNOWFLAKE_ID_WEAPON:
      return <SnowflakeWeapon module={module} />;
    case MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC:
      return <SnowflakeWeaponBallistic module={module} />;
    case MECHA_SNOWFLAKE_ID_EJECTOR:
      return <SnowflakeEjector module={module} />;
    case MECHA_SNOWFLAKE_ID_EXTINGUISHER:
      return <SnowflakeExtinguisher module={module} />;
    case MECHA_SNOWFLAKE_ID_OREBOX_MANAGER:
      return <SnowflakeOrebox module={module} />;
    case MECHA_SNOWFLAKE_ID_SLEEPER:
      return <SnowflakeSleeper module={module} />;
    case MECHA_SNOWFLAKE_ID_SYRINGE:
      return <SnowflakeSyringe module={module} />;
    case MECHA_SNOWFLAKE_ID_MODE:
      return <SnowflakeMode module={module} />;
    case MECHA_SNOWFLAKE_ID_RADIO:
      return <SnowflakeRadio module={module} />;
    case MECHA_SNOWFLAKE_ID_AIR_TANK:
      return <SnowflakeAirTank module={module} />;
    default:
      return <DefaultModule module={module} />;
  }
};

const DefaultModule = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { power_level, weapons_safety } = data;
  const { ref, energy_per_use } = props.module;
  const { integrity } = props.module.snowflake;
  return (
    <Box
      style={{
        'word-break': 'break-all',
        'word-wrap': 'break-word',
      }}>
      <LabeledList>
        {!!weapons_safety && (
          <LabeledList.Item label="Safety" color="red">
            SAFETY OVERRIDE IN EFFECT
          </LabeledList.Item>
        )}
        {integrity < 1 && (
          <LabeledList.Item
            label="Integrity"
            buttons={
              <Button
                content={'Repair'}
                icon={'wrench'}
                onClick={() =>
                  act('equip_act', {
                    ref: ref,
                    gear_action: 'repair',
                  })
                }
              />
            }>
            <ProgressBar
              ranges={{
                good: [0.75, Infinity],
                average: [0.25, 0.75],
                bad: [-Infinity, 0.25],
              }}
              value={integrity}
            />
          </LabeledList.Item>
        )}
        {!!energy_per_use && (
          <LabeledList.Item label="Power Cost">
            {`${formatPower(energy_per_use)}, ${
              power_level ? toFixed(power_level / energy_per_use) : 0
            } uses left`}
          </LabeledList.Item>
        )}
      </LabeledList>
      {/* {JSON.stringify(props.module.snowflake)} */}
    </Box>
  );
};

const SnowflakeWeapon = (props: { module: MechModule }, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { power_level, weapons_safety } = data;
  const { ref, energy_per_use } = props.module;
  const { integrity } = props.module.snowflake;
  return (
    <LabeledList>
      {!!weapons_safety && (
        <LabeledList.Item label="Safety" color="red">
          SAFETY OVERRIDE IN EFFECT
        </LabeledList.Item>
      )}
      {integrity < 1 && (
        <LabeledList.Item
          label="Integrity"
          buttons={
            <Button
              content={'Repair'}
              icon={'wrench'}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'repair',
                })
              }
            />
          }>
          <ProgressBar
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }}
            value={integrity}
          />
        </LabeledList.Item>
      )}
      <LabeledList.Item label="Power Cost">
        {`${formatPower(energy_per_use)}, ${
          power_level ? toFixed(power_level / energy_per_use) : 0
        } uses left`}
      </LabeledList.Item>
    </LabeledList>
  );
};

const SnowflakeWeaponBallistic = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { weapons_safety } = data;
  const { ref } = props.module;
  const {
    integrity,
    projectiles,
    max_magazine,
    projectiles_cache,
    projectiles_cache_max,
    disabledreload,
    ammo_type,
  } = props.module.snowflake;
  return (
    <LabeledList>
      {!!weapons_safety && (
        <LabeledList.Item label="Safety" color="red">
          SAFETY OVERRIDE IN EFFECT
        </LabeledList.Item>
      )}
      {integrity < 1 && (
        <LabeledList.Item
          label="Integrity"
          buttons={
            <Button
              content={'Repair'}
              icon={'wrench'}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'repair',
                })
              }
            />
          }>
          <ProgressBar
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }}
            value={integrity}
          />
        </LabeledList.Item>
      )}
      <LabeledList.Item label="Ammunition">{ammo_type}</LabeledList.Item>
      <LabeledList.Item
        label="Loaded"
        buttons={
          !disabledreload && (
            <Button
              icon={'redo'}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: 'reload',
                })
              }>
              Reload
            </Button>
          )
        }>
        <ProgressBar value={projectiles / max_magazine}>
          {`${projectiles} of ${max_magazine}`}
        </ProgressBar>
      </LabeledList.Item>
      {!!projectiles_cache_max && (
        <LabeledList.Item label="Stored">
          <ProgressBar value={projectiles_cache / projectiles_cache_max}>
            {`${projectiles_cache} of ${projectiles_cache_max}`}
          </ProgressBar>
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};

const SnowflakeSleeper = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { integrity, energy_per_use } = props.module.snowflake;
  return (
    <Box
      style={{
        'word-break': 'break-all',
        'word-wrap': 'break-word',
      }}>
      {JSON.stringify(props.module.snowflake)}
    </Box>
  );
};

const SnowflakeSyringe = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { integrity, energy_per_use } = props.module.snowflake;
  return (
    <Box
      style={{
        'word-break': 'break-all',
        'word-wrap': 'break-word',
      }}>
      {JSON.stringify(props.module.snowflake)}
    </Box>
  );
};

const SnowflakeMode = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { integrity, energy_per_use } = props.module.snowflake;
  return (
    <Box
      style={{
        'word-break': 'break-all',
        'word-wrap': 'break-word',
      }}>
      {JSON.stringify(props.module.snowflake)}
    </Box>
  );
};

const SnowflakeRadio = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { microphone, speaker, minFrequency, maxFrequency, frequency } =
    props.module.snowflake;
  return (
    <LabeledList>
      <LabeledList.Item label="Microphone">
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_microphone',
            })
          }
          selected={microphone}
          icon={microphone ? 'microphone' : 'microphone-slash'}>
          {(microphone ? 'En' : 'Dis') + 'abled'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Speaker">
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_speaker',
            })
          }
          selected={speaker}
          icon={speaker ? 'volume-up' : 'volume-mute'}>
          {(speaker ? 'En' : 'Dis') + 'abled'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Frequency">
        <NumberInput
          animate
          unit="kHz"
          step={0.2}
          stepPixelSize={10}
          minValue={minFrequency / 10}
          maxValue={maxFrequency / 10}
          value={frequency / 10}
          format={(value) => toFixed(value, 1)}
          onDrag={(e, value) =>
            act('equip_act', {
              ref: ref,
              gear_action: 'set_frequency',
              new_frequency: value * 10,
            })
          }
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const SnowflakeAirTank = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { integrity, energy_per_use } = props.module.snowflake;
  return (
    <Box
      style={{
        'word-break': 'break-all',
        'word-wrap': 'break-word',
      }}>
      {JSON.stringify(props.module.snowflake)}
    </Box>
  );
};

const SnowflakeOrebox = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { cargo } = props.module.snowflake;
  return (
    <Box>
      <Button
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'dump',
          })
        }
        disabled={!cargo}>
        {cargo ? 'Dump contents' : 'Empty'}
      </Button>
    </Box>
  );
};

const SnowflakeEjector = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { ref } = props.module;
  const { cargo } = props.module.snowflake;
  return (
    <Box>
      {!cargo.length ? (
        <NoticeBox info>Compartment is empty</NoticeBox>
      ) : (
        cargo.map((item, i) => (
          <Stack key={i} mb={1} style={{ 'text-transform': 'capitalize' }}>
            <Stack.Item>
              <Button
                icon="eject"
                tooltip="Eject"
                onClick={() =>
                  act('equip_act', {
                    ref: ref,
                    cargoref: item.ref,
                    gear_action: 'eject',
                  })
                }
              />
            </Stack.Item>
            <Stack.Item grow lineHeight={1.5}>
              {item.name}
            </Stack.Item>
          </Stack>
        ))
      )}
    </Box>
  );
};

const SnowflakeExtinguisher = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  return (
    <>
      <ProgressBar
        value={props.module.snowflake.reagents}
        minValue={0}
        maxValue={props.module.snowflake.total_reagents}>
        {props.module.snowflake.reagents}
      </ProgressBar>
      <Button
        tooltip={'ACTIVATE'}
        color={'red'}
        disabled={
          props.module.snowflake.reagents < props.module.snowflake.minimum_requ
            ? 1
            : 0
        }
        icon={'fire-extinguisher'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'activate',
          })
        }
      />
      <Button
        tooltip={'REFILL'}
        icon={'fill'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'refill',
          })
        }
      />
      <Button
        tooltip={'REPAIR'}
        icon={'wrench'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'repair',
          })
        }
      />
      <Button
        tooltip={'DETACH'}
        icon={'arrow-down'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'detach',
          })
        }
      />
    </>
  );
};

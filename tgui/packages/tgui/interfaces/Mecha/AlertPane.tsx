import { useBackend } from '../../backend';
import { Section, Stack, Button, Box, Icon, Dimmer } from '../../components';
import { MainData } from './data';

export const InternalDamageToDamagedDesc = {
  'MECHA_INT_FIRE': 'Internal fire detected',
  'MECHA_INT_TEMP_CONTROL': 'Thermoregulator offline',
  'MECHA_CABIN_AIR_BREACH': 'Cabin breach detected',
  'MECHA_INT_CONTROL_LOST': 'Motors damaged',
  'MECHA_INT_SHORT_CIRCUIT': 'Circuits shorted',
};

export const InternalDamageToNormalDesc = {
  'MECHA_INT_FIRE': 'No internal fires detected',
  'MECHA_INT_TEMP_CONTROL': 'Thermoregulator active',
  'MECHA_CABIN_AIR_BREACH': 'Cabin sealing intact',
  'MECHA_INT_CONTROL_LOST': 'Motors active',
  'MECHA_INT_SHORT_CIRCUIT': 'Circuits operational',
};

export const AlertPane = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const {
    internal_damage,
    internal_damage_keys,
    servo_rating,
    scanmod_rating,
    capacitor_rating,
    can_use_overclock,
    overclock_safety_available,
    overclock_safety,
    overclock_mode,
    overclock_temp_percentage,
  } = data;
  return (
    <Section
      title="Status"
      buttons={
        (!!overclock_mode || !!can_use_overclock) && (
          <>
            <Button
              icon="forward"
              onClick={() => !!can_use_overclock && act('toggle_overclock')}
              color={
                overclock_mode &&
                (overclock_temp_percentage > 1
                  ? 'bad'
                  : overclock_temp_percentage > 0.5
                    ? 'average'
                    : 'good')
              }>
              {overclock_mode
                ? `Overclocking (${Math.round(
                  overclock_temp_percentage * 100
                )}%)`
                : 'Overclock'}
            </Button>
            {!!overclock_safety_available && (
              <Button
                icon={
                  overclock_safety
                    ? 'temperature-arrow-down'
                    : 'temperature-arrow-up'
                }
                onClick={() => act('toggle_overclock_safety')}
                color={overclock_safety ? 'good' : 'bad'}
                tooltip={
                  overclock_safety
                    ? 'OC safety prevents overheat.'
                    : 'OC safety disabled.'
                }
              />
            )}
          </>
        )
      }>
      <Stack vertical>
        {!scanmod_rating ? (
          <Box height={8}>
            <Dimmer>Scanning module missing.</Dimmer>
          </Box>
        ) : (
          Object.keys(internal_damage_keys).map((t) => (
            <Stack.Item key={t}>
              <Stack justify="space-between">
                <Stack.Item>
                  <Box
                    color={
                      internal_damage & internal_damage_keys[t]
                        ? 'red'
                        : 'green'
                    }>
                    <Icon
                      mr={1}
                      name={
                        internal_damage & internal_damage_keys[t]
                          ? 'warning'
                          : 'check'
                      }
                    />
                    {internal_damage & internal_damage_keys[t]
                      ? InternalDamageToDamagedDesc[t]
                      : InternalDamageToNormalDesc[t]}
                  </Box>
                </Stack.Item>
                {!!(internal_damage & internal_damage_keys[t]) && (
                  <Stack.Item>
                    <Button
                      my="-4px"
                      onClick={() =>
                        act('repair_int_damage', {
                          flag: internal_damage_keys[t],
                        })
                      }
                      color={'red'}>
                      Repair
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          ))
        )}
      </Stack>
    </Section>
  );
};

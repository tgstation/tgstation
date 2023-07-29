import { useBackend } from '../../backend';
import { Section, Stack, Button, Box, Icon } from '../../components';
import { MainData, InternalDamageToDamagedDesc, InternalDamageToNormalDesc } from './data';

export const AlertPane = (props, context) => {
  const { act, data } = useBackend<MainData>(context);
  const { internal_damage, internal_damage_keys } = data;
  return (
    <Section title="Status">
      <Stack vertical>
        {Object.keys(internal_damage_keys).map((t) => (
          <Stack.Item key={t}>
            <Stack justify="space-between">
              <Stack.Item>
                <Box
                  color={
                    internal_damage & internal_damage_keys[t] ? 'red' : 'green'
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
        ))}
      </Stack>
    </Section>
  );
};

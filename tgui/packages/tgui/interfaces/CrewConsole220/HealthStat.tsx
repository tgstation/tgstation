import { Stack } from 'tgui-core/components';

import { COLORS } from '../../constants';
import { STAT_DEAD } from './constants';

export function HealthStat(props) {
  const { sensor_data } = props;
  const { oxydam, toxdam, burndam, brutedam, life_status } = sensor_data;
  return (
    <Stack fill textAlign="center">
      {oxydam !== undefined ? (
        <>
          <Stack.Item color={COLORS.damageType.oxy}>{oxydam}</Stack.Item>
          <Stack.Divider />
          <Stack.Item color={COLORS.damageType.toxin}>{toxdam}</Stack.Item>
          <Stack.Divider />
          <Stack.Item color={COLORS.damageType.burn}>{burndam}</Stack.Item>
          <Stack.Divider />
          <Stack.Item color={COLORS.damageType.brute}>{brutedam}</Stack.Item>
        </>
      ) : life_status !== STAT_DEAD ? (
        <Stack.Item grow>Живой</Stack.Item>
      ) : (
        <Stack.Item grow>Мёртв</Stack.Item>
      )}
    </Stack>
  );
}

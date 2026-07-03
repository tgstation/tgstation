import { Icon, Stack, Tooltip } from 'tgui-core/components';

export function ShowPing(props) {
  const { user } = props;
  const ping = user?.ping;

  return (
    <Stack wrap>
      <Tooltip content="Текущий пинг" position="bottom-end">
        <Stack.Item color="green">
          <Icon mr={1} name="clock-rotate-left" />
          {ping ? `${Math.round(ping.lastPing)}ms` : <Icon name="infinity" />}
        </Stack.Item>
      </Tooltip>
      <Stack.Divider />
      <Tooltip content="Средний пинг" position="bottom-end">
        <Stack.Item color="orange">
          <Icon mr={1} name="chart-simple" />
          {ping ? `${Math.round(ping.avgPing)}ms` : <Icon name="infinity" />}
        </Stack.Item>
      </Tooltip>
    </Stack>
  );
}

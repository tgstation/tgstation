import { Dimmer, Icon, Stack } from 'tgui-core/components';

export function PointLocked(props) {
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon color="purple" name="dollar-sign" size={10} />
          <div
            style={{
              background: 'purple',
              bottom: '60%',
              left: '33%',
              height: '10px',
              position: 'relative',
              transform: 'rotate(45deg)',
              width: '150px',
            }}
          />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="purple">
          У вас недостаточно очков для использования этой страницы.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
}

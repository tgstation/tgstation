import { Box, Button, Stack } from 'tgui-core/components';

export type ControlBarProps = {
  running: boolean;
  zoom: number;
  awaitingPick: boolean;
  autoScroll: boolean;
  onAutoScrollChange: (val: boolean) => void;
  act: (action: string, params?: object) => void;
};

export function ControlBar(props: ControlBarProps) {
  const { running, zoom, awaitingPick, autoScroll, onAutoScrollChange, act } =
    props;
  return (
    <Stack align="center" p={0.5}>
      <Stack.Item>
        <Button
          icon={running ? 'stop' : 'play'}
          color={running ? 'bad' : 'good'}
          onClick={() => act('toggle_running')}
        >
          {running ? 'Stop' : 'Start'}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="trash"
          color="average"
          onClick={() => act('clear')}
          disabled={running}
        >
          Clear
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="crosshairs"
          color={awaitingPick ? 'caution' : 'transparent'}
          selected={awaitingPick}
          onClick={() => act('start_pick_target')}
        >
          {awaitingPick ? 'Click a target...' : 'Pick Target'}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angles-right"
          selected={autoScroll}
          tooltip="Auto-scroll timeline to the latest event"
          onClick={() => onAutoScrollChange(!autoScroll)}
        >
          Auto-Scroll
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Box inline color="label">
          Zoom: {zoom < 1 ? zoom.toFixed(1) : zoom}x
        </Box>
      </Stack.Item>
    </Stack>
  );
}

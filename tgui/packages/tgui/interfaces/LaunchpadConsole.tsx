import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  launchpads: LaunchPad[];
  pad_active: number;
  pad_name: string;
  range: number;
  selected_id: number;
  selected_pad: string;
  x: number;
  y: number;
};

type LaunchPad = {
  id: number;
  name: string;
};

const buttonConfigs = [
  [
    { icon: 'arrow-left', iconRotation: 45, x: -1, y: 1 },
    { icon: 'arrow-left', x: -1 },
    { icon: 'arrow-down', iconRotation: 45, x: -1, y: -1 },
  ],
  [
    { icon: 'arrow-up', y: 1 },
    { text: 'R', x: 0, y: 0 },
    { icon: 'arrow-down', y: -1 },
  ],
  [
    { icon: 'arrow-up', iconRotation: 45, x: 1, y: 1 },
    { icon: 'arrow-right', x: 1 },
    { icon: 'arrow-right', iconRotation: 45, x: 1, y: -1 },
  ],
] as const;

export function LaunchpadConsole(props) {
  const { data } = useBackend<Data>();
  const { launchpads = [], selected_id } = data;

  return (
    <Window width={475} height={260}>
      <Window.Content>
        {launchpads.length === 0 ? (
          <NoticeBox>No Pads Connected</NoticeBox>
        ) : (
          <Stack fill>
            <Stack.Item grow>
              <LaunchpadTabs />
            </Stack.Item>

            <Stack.Item grow={3}>
              {!selected_id ? (
                <Box>Please select a pad</Box>
              ) : (
                <LaunchpadControl />
              )}
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
}

export function LaunchpadControl(props) {
  return (
    <Stack fill vertical>
      <Stack.Item>
        <LaunchpadTitle />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill>
          <Stack fill>
            <Stack.Item grow>
              <LaunchpadButtonPad />
            </Stack.Item>
            <Stack.Item grow>
              <TargetingControls />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <DeliveryButtons />
      </Stack.Item>
    </Stack>
  );
}

function LaunchpadTabs(props) {
  const { act, data } = useBackend<Data>();
  const { launchpads = [], selected_id } = data;

  return (
    <Section fill>
      <Tabs vertical>
        {launchpads.map((pad) => (
          <Tabs.Tab
            key={pad.id}
            selected={pad.id === selected_id}
            onClick={() =>
              act('select_pad', {
                id: pad.id,
              })
            }
          >
            {pad.name}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
}

function LaunchpadTitle(props) {
  const { act, data } = useBackend<Data>();
  const { pad_name } = data;

  return (
    <Section>
      <Stack fill>
        <Stack.Item grow>
          <Input
            expensive
            value={pad_name}
            width="170px"
            onChange={(value) =>
              act('rename', {
                name: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button icon="times" color="bad" onClick={() => act('remove')}>
            Remove
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function LaunchpadButtonPad(props) {
  const { act } = useBackend();

  return (
    <Section fill title="Controls" align="center">
      <Stack fill justify="center">
        {buttonConfigs.map((buttonRow, i) => (
          <Stack.Item key={i}>
            {buttonRow.map((buttonConfig, j) => (
              <Button
                fluid
                icon={buttonConfig.icon}
                iconRotation={buttonConfig.iconRotation}
                key={j}
                mb={1}
                onClick={() =>
                  act('move_pos', {
                    x: buttonConfig.x,
                    y: buttonConfig.y,
                  })
                }
              >
                {buttonConfig.text}
              </Button>
            ))}
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function TargetingControls(props) {
  const { act, data } = useBackend<Data>();
  const { x, y, range } = data;

  const inputConfigs = [
    { value: x, axis: 'x', icon: 'arrows-alt-h' },
    { value: y, axis: 'y', icon: 'arrows-alt-v' },
  ];

  return (
    <Section fill title="Target" align="center">
      {inputConfigs.map((inputConfig, i) => (
        <Stack key={i} mb={2}>
          <Stack.Item grow>
            <Box fontSize="26px">
              {inputConfig.axis.toUpperCase()} <Icon name={inputConfig.icon} />
            </Box>
          </Stack.Item>
          <Stack.Item>
            <NumberInput
              fontSize="26px"
              height="30px"
              lineHeight="30px"
              maxValue={range}
              minValue={-range}
              onChange={(value) =>
                act('set_pos', {
                  [inputConfig.axis]: value,
                })
              }
              step={1}
              stepPixelSize={10}
              value={inputConfig.value}
              width="90px"
            />
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
}

function DeliveryButtons(props) {
  const { act } = useBackend();

  return (
    <Section fill>
      <Stack fill>
        <Stack.Item grow>
          <Button
            fluid
            icon="upload"
            onClick={() => act('launch')}
            textAlign="center"
          >
            Launch
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="download"
            onClick={() => act('pull')}
            textAlign="center"
          >
            Pull
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

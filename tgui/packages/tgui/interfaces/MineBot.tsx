import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

import { useBackend } from '../backend';
import {
  Button,
  Image,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';

type Data = {
  auto_defend: BooleanLike;
  repair_node_drone: BooleanLike;
  plant_mines: BooleanLike;
  bot_mode: BooleanLike;
  bot_name: string;
  bot_health: number;
  bot_maxhealth: number;
  bot_icon: string;
};

export const MineBot = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    auto_defend,
    repair_node_drone,
    plant_mines,
    bot_name,
    bot_health,
    bot_mode,
    bot_maxhealth,
    bot_icon,
  } = data;
  return (
    <Window title="Minebot Settings" width={625} height={250} theme="hackerman">
      <Window.Content>
        <Stack>
          <Stack.Item width="50%">
            <Section
              textAlign="center"
              title={bot_name}
              buttons={
                <Button.Input
                  color="transparent"
                  onCommit={(e, value) =>
                    act('set_name', {
                      chosen_name: value,
                    })
                  }
                >
                  Rename
                </Button.Input>
              }
            >
              <Image
                m={1}
                src={`data:image/jpeg;base64,${bot_icon}`}
                height="160px"
                width="160px"
                style={{
                  verticalAlign: 'middle',
                  borderRadius: '1em',
                  border: '1px solid green',
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item width="50%" textAlign="center">
            <Section title="Configurations">
              <LabeledList>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    value={bot_health}
                    maxValue={bot_maxhealth}
                    color="white"
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Mode">
                  <Button
                    textAlign="center"
                    width="50%"
                    style={{ padding: '3px' }}
                    onClick={() => act('toggle_mode')}
                  >
                    {bot_mode ? 'Combat' : 'Safe'}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Repair Node Drones">
                  <Button
                    textAlign="center"
                    width="50%"
                    style={{ padding: '3px' }}
                    onClick={() => act('toggle_repair')}
                  >
                    {repair_node_drone ? 'Repair' : 'Ignore'}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Plant Mines">
                  <Button
                    textAlign="center"
                    width="50%"
                    style={{ padding: '3px' }}
                    onClick={() => act('toggle_mines')}
                  >
                    {plant_mines ? 'On' : 'Off'}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Auto protect">
                  <Button
                    textAlign="center"
                    width="50%"
                    style={{ padding: '3px' }}
                    onClick={() => act('toggle_defend')}
                  >
                    {auto_defend ? 'On' : 'Off'}
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

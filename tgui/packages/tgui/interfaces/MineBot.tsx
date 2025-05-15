import { useState } from 'react';
import {
  Button,
  Dropdown,
  Image,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  auto_defend: BooleanLike;
  repair_node_drone: BooleanLike;
  plant_mines: BooleanLike;
  bot_mode: BooleanLike;
  bot_name: string;
  bot_health: number;
  bot_maintain_distance: number;
  bot_maxhealth: number;
  bot_icon: string;
  bot_color: string;
  possible_colors: Possible_Colors[];
};

type Possible_Colors = {
  color_name: string;
  color_value: string;
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
    possible_colors,
    bot_maintain_distance,
    bot_color,
    bot_icon,
  } = data;
  const possibleColorList = {};
  for (const index in possible_colors) {
    const color = possible_colors[index];
    possibleColorList[color.color_name] = color;
  }
  const [selectedDistance, setSelectedDistance] = useState(
    bot_maintain_distance,
  );
  const [selectedColor, setSelectedColor] = useState(
    possibleColorList[bot_color],
  );
  return (
    <Window title="Minebot Settings" width={625} height={328} theme="hackerman">
      <Window.Content>
        <Stack>
          <Stack.Item width="50%">
            <Section
              textAlign="center"
              title={bot_name}
              buttons={
                <Button.Input
                  buttonText="Rename"
                  color="transparent"
                  onCommit={(value) =>
                    act('set_name', {
                      chosen_name: value,
                    })
                  }
                />
              }
            >
              <Stack vertical>
                <Stack.Item>
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
                </Stack.Item>
                <Stack.Item ml="25%">
                  <Dropdown
                    width="65%"
                    selected={selectedColor?.color_name}
                    options={possible_colors.map((possible_color) => {
                      return possible_color.color_name;
                    })}
                    onSelected={(selected) =>
                      setSelectedColor(possibleColorList[selected])
                    }
                  />
                </Stack.Item>
                <Stack.Item textAlign="center">
                  <Button
                    textAlign="center"
                    width="50%"
                    style={{ padding: '3px' }}
                    onClick={() =>
                      act('set_color', {
                        chosen_color: selectedColor?.color_value,
                      })
                    }
                  >
                    Apply Color
                  </Button>
                </Stack.Item>
              </Stack>
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
                <LabeledList.Item label="Distance To Maintain">
                  <NumberInput
                    width="50%"
                    value={selectedDistance}
                    minValue={0}
                    step={1}
                    maxValue={5}
                    onChange={(value) =>
                      act('change_min_distance', {
                        distance: value,
                      })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

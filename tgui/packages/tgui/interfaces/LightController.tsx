import { useState } from 'react';
import {
  Box,
  Button,
  Knob,
  Section,
  Slider,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import { BooleanLike, classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

enum Direction {
  North = 1,
  South = 2,
  East = 4,
  West = 8,
}

type LightDetails = {
  name: string;
  color: string;
  power: number;
  range: number;
  angle: number;
};

type TemplateID = string;

type LightTemplate = {
  light_info: LightDetails;
  description: string;
  id: TemplateID;
};

interface CategoryList {
  [key: string]: TemplateID[];
}

type Data = {
  on: BooleanLike;
  direction: number;
  light_info: LightDetails;
  templates: LightTemplate[];
  default_id: string;
  default_category: string;
  category_ids: CategoryList;
};

export const LightController = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    light_info,
    templates = [],
    default_id,
    default_category,
    category_ids,
  } = data;
  const [currentTemplate, setCurrentTemplate] = useState(default_id);
  const [currentCategory, setCurrentCategory] = useState(default_category);

  const category_keys = category_ids ? Object.keys(category_ids) : [];

  return (
    <Window title={light_info.name + ': Lighting'} width={600} height={400}>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item>
            <Section fitted fill scrollable width="170px">
              <Tabs fluid align="center">
                {category_keys.map((category, index) => (
                  <Tabs.Tab
                    key={category}
                    selected={currentCategory === category}
                    onClick={() => setCurrentCategory(category)}
                  >
                    <Box fontSize="14px" bold textColor="#eee">
                      {category}
                    </Box>
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Tabs vertical>
                {category_ids[currentCategory].map((id) => (
                  <Tabs.Tab
                    key={id}
                    selected={currentTemplate === id}
                    onClick={() => setCurrentTemplate(id)}
                  >
                    <Box fontSize="14px" textColor="#cee">
                      {templates[id].light_info.name}
                    </Box>
                    <Box
                      ml={0.1}
                      className={classes([
                        'lights32x32',
                        'light_fantastic_' + id,
                      ])}
                    />
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <LightControl info={light_info} />
            <LightInfo light={templates[currentTemplate]} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type LightControlProps = {
  info: LightDetails;
};

const LightControl = (props: LightControlProps) => {
  const { act, data } = useBackend<Data>();
  const { on } = data;
  const { info } = props;
  return (
    <Section>
      <Stack vertical justify="space-between" fill>
        <Stack.Item>
          <Stack justify="space-between">
            <Stack.Item>
              <Box fontSize="16px" mt={0.5}>
                {info.name}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                fontSize="16px"
                icon="brush"
                tooltip="Change light color"
                textColor={info.color}
                onClick={() => act('change_color')}
              >
                {info.color}
              </Button>
              <Button
                fontSize="16px"
                color={on ? 'good' : 'bad'}
                icon="power-off"
                tooltip="Enable/Disable the light"
                onClick={() =>
                  act('set_on', {
                    value: !on,
                  })
                }
              />
              <Button
                fontSize="16px"
                color="purple"
                icon="handcuffs"
                tooltip="Isolate this light for a bit"
                onClick={() => act('isolate')}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack justify="space-around">
            <Stack.Item>
              <Section title="Direction" textAlign="center" fontSize="11px">
                <DirectionSelect />
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Angle" textAlign="center" fontSize="11px">
                <AngleSelect />
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item align="end">
          <Slider
            unit="tiles"
            value={info.range}
            color="blue"
            minValue={0}
            maxValue={10}
            onChange={(e, value) =>
              act('set_range', {
                value: value,
              })
            }
            step={0.1}
            stepPixelSize={5}
          />
          <Slider
            unit="intensity"
            value={info.power}
            color="olive"
            minValue={-1}
            maxValue={5}
            format={(value) => round(value, 2).toString()}
            onChange={(e, value) =>
              act('set_power', {
                value: value,
              })
            }
            step={0.1}
            stepPixelSize={10}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type LightInfoProps = {
  light: LightTemplate;
};

const LightInfo = (props: LightInfoProps) => {
  const { act } = useBackend();
  const { light } = props;
  const { light_info } = light;
  return (
    <Section>
      <Stack vertical justify="space-between" fill>
        <Stack.Item>
          <Stack justify="space-between">
            <Stack.Item>
              <Box fontSize="16px" mt={0.5}>
                Template: {light_info.name}
              </Box>
              <Box fontSize="12px" ml={1} color="#aaaaaa">
                {light.description}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button fontSize="16px" icon="brush" textColor={light_info.color}>
                {light_info.color}
              </Button>
              <Button
                fontSize="16px"
                icon="upload"
                tooltip="Use template"
                onClick={() =>
                  act('mirror_template', {
                    id: light.id,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item align="end">
          <Slider
            unit="tiles"
            value={light_info.range}
            color="blue"
            minValue={0}
            maxValue={10}
            step={0}
          />
          <Slider
            unit="intensity"
            value={light_info.power}
            color="olive"
            minValue={-1}
            maxValue={5}
            step={0}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// 3 vertical stacks, setup as columns
const DirectionSelect = () => {
  return (
    <Stack align="start" mt={0.5}>
      <Stack.Item align="center">
        <DirectionButton icon="arrow-left" dir={Direction.West} />
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <DirectionButton icon="arrow-up" dir={Direction.North} />
          </Stack.Item>
          <Stack.Item>
            <Box backgroundColor="grey" width="18px" height="18px" ml="2px" />
          </Stack.Item>
          <Stack.Item>
            <DirectionButton icon="arrow-down" dir={Direction.South} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item align="center">
        <DirectionButton icon="arrow-right" dir={Direction.East} />
      </Stack.Item>
    </Stack>
  );
};

type DirectedButtonProps = {
  dir: number;
  icon: string;
};

const DirectionButton = (props: DirectedButtonProps) => {
  const { act, data } = useBackend<Data>();
  const { direction } = data;
  const { dir, icon } = props;
  return (
    <Button
      icon={icon}
      selected={direction & dir}
      onClick={() =>
        act('set_dir', {
          value: dir,
        })
      }
    />
  );
};

const AngleSelect = (props) => {
  const { act, data } = useBackend<Data>();
  const { light_info } = data;
  const { angle } = light_info;
  return (
    <Knob
      mt={0.5}
      value={angle}
      minValue={0}
      maxValue={360}
      animated
      size={2.2}
      step={5}
      stepPixelSize={10}
      onChange={(e, value) =>
        act('set_angle', {
          value: value,
        })
      }
    />
  );
};

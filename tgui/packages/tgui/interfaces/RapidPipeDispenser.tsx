import { BooleanLike, classes } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  ColorBox,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const ROOT_CATEGORIES = ['Atmospherics', 'Disposals', 'Transit Tubes'];

export const ICON_BY_CATEGORY_NAME = {
  Atmospherics: 'wrench',
  Disposals: 'trash-alt',
  'Transit Tubes': 'bus',
  Pipes: 'grip-lines',
  Binary: 'arrows-left-right',
  'Disposal Pipes': 'grip-lines',
  Devices: 'microchip',
  'Heat Exchange': 'thermometer-half',
  'Station Equipment': 'microchip',
};

const TOOLS = [
  {
    name: 'Dispense',
    bitmask: 1,
  },
  {
    name: 'Connect',
    bitmask: 2,
  },
  {
    name: 'Destroy',
    bitmask: 4,
  },
  {
    name: 'Reprogram',
    bitmask: 8,
  },
];

const LAYERS = [
  {
    name: '1',
    bitmask: 1,
  },
  {
    name: '2',
    bitmask: 2,
  },
  {
    name: '3',
    bitmask: 4,
  },
  {
    name: '4',
    bitmask: 8,
  },
  {
    name: '5',
    bitmask: 16,
  },
] as const;

type DirectionsAllowed = {
  north: BooleanLike;
  south: BooleanLike;
  east: BooleanLike;
  west: BooleanLike;
};

type Colors = {
  green: string;
  blue: string;
  red: string;
  orange: string;
  cyan: string;
  dark: string;
  yellow: string;
  brown: string;
  pink: string;
  purple: string;
  violet: string;
  omni: string;
};

type Category = {
  cat_name: string;
  recipes: Recipe[];
};

type Recipe = {
  pipe_name: string;
  pipe_index: number;
  previews: Preview[];
};

type Preview = {
  selected: BooleanLike;
  dir: string;
  dir_name: string;
  icon_state: string;
  flipped: BooleanLike;
};

type Data = {
  // Dynamic
  category: number;
  pipe_layers: number;
  multi_layer: BooleanLike;
  ducting_layer: number;
  categories: Category[];
  selected_recipe: string;
  selected_color: string;
  selected_category: string;
  mode: number;
  init_directions: DirectionsAllowed;
  // Static
  paint_colors: Colors;
};

export const ColorItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { selected_color, paint_colors } = data;
  const colorNames = Object.keys(paint_colors);
  return (
    <LabeledList.Item label="Color">
      {colorNames.map((colorName) => (
        <ColorBox
          key={colorName}
          height="20px"
          width="20px"
          style={{
            border:
              '3px solid ' +
              (colorName === selected_color ? '#20b142' : '#222'),
          }}
          color={paint_colors[colorName]}
          onClick={() =>
            act('color', {
              paint_color: colorName,
            })
          }
        />
      ))}
      <Box inline ml={2} px={1} bold color={paint_colors[selected_color]}>
        {capitalizeAll(selected_color)}
      </Box>
    </LabeledList.Item>
  );
};

const ModeItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { mode } = data;
  return (
    <LabeledList.Item label="Modes">
      {TOOLS.map((tool) => (
        <Button.Checkbox
          key={tool.bitmask}
          checked={mode & tool.bitmask}
          content={tool.name}
          onClick={() =>
            act('mode', {
              mode: tool.bitmask,
            })
          }
        />
      ))}
    </LabeledList.Item>
  );
};

const CategoryItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { category: rootCategoryIndex } = data;
  return (
    <LabeledList.Item label="Category">
      {ROOT_CATEGORIES.map((categoryName, i) => (
        <Button
          key={categoryName}
          selected={rootCategoryIndex === i}
          icon={ICON_BY_CATEGORY_NAME[categoryName]}
          color="transparent"
          onClick={() => act('category', { category: i })}
        >
          {categoryName}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

const SelectionSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { category: rootCategoryIndex } = data;
  return (
    <Section fill>
      <LabeledList>
        <CategoryItem />
        <ModeItem />
        {rootCategoryIndex === 0 && <ColorItem />}
        {rootCategoryIndex === 0 && <LayerSelect />}
      </LabeledList>
    </Section>
  );
};

const LayerSelect = (props) => {
  const { act, data } = useBackend<Data>();
  const { pipe_layers } = data;
  const { multi_layer } = data;
  return (
    <LabeledList.Item label="Layer">
      {LAYERS.map((layer) => (
        <Button.Checkbox
          key={layer.bitmask}
          checked={
            multi_layer
              ? pipe_layers & layer.bitmask
              : layer.bitmask === pipe_layers
          }
          content={layer.name}
          onClick={() => act('pipe_layers', { pipe_layers: layer.bitmask })}
        />
      ))}
      <Button.Checkbox
        key="multilayer"
        checked={multi_layer}
        content="Multi"
        tooltip="Build on multiple pipe layers simultaneously"
        onClick={() => {
          act('toggle_multi_layer');
        }}
      />
    </LabeledList.Item>
  );
};

const PreviewSelect = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Box>
      {props.previews.map((preview) => (
        <Button
          ml={0}
          key={preview.dir}
          tooltip={preview.dir_name}
          selected={preview.selected}
          style={{
            width: '40px',
            height: '40px',
            padding: '0',
          }}
          onClick={() => {
            act('pipe_type', {
              pipe_type: props.pipe_type,
              category: props.category,
            });
            act('setdir', {
              dir: preview.dir,
              flipped: preview.flipped,
            });
          }}
        >
          <Box
            className={classes([
              'pipes32x32',
              preview.dir + '-' + preview.icon_state,
            ])}
            style={{
              transform: 'scale(1.5) translate(9.5%, 9.5%)',
            }}
          />
        </Button>
      ))}
    </Box>
  );
};

const PipeTypeSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], selected_category, selected_recipe } = data;
  const [categoryName, setCategoryName] = useState(selected_category);
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];

  return (
    <Section>
      <Tabs>
        {categories.map((category, i) => (
          <Tabs.Tab
            key={category.cat_name}
            icon={ICON_BY_CATEGORY_NAME[category.cat_name]}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}
          >
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Table>
        {shownCategory?.recipes.map((recipe) => (
          <Table.Row
            key={recipe.pipe_index}
            style={{ borderBottom: '1px solid #333' }}
          >
            <Table.Cell collapsing py="2px" pb="1px">
              <PreviewSelect
                previews={recipe.previews}
                pipe_type={recipe.pipe_index}
                category={shownCategory.cat_name}
              />
            </Table.Cell>
            <Table.Cell />
            <Table.Cell style={{ verticalAlign: 'middle' }}>
              {recipe.pipe_name}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

export const SmartPipeBlockSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { init_directions = [] } = data;
  return (
    <Section fill>
      <Stack vertical textAlign="center">
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                color="transparent"
                icon="info"
                tooltipPosition="right"
                tooltip="This is a panel for blocking certain connection
                directions for the smart pipes.
                The button in the center resets to
                default (all directions can connect)"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="arrow-up"
                selected={init_directions['north']}
                onClick={() =>
                  act('init_dir_setting', {
                    dir_flag: 'north',
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                icon="arrow-left"
                selected={init_directions['west']}
                onClick={() =>
                  act('init_dir_setting', {
                    dir_flag: 'west',
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button icon="circle" onClick={() => act('init_reset', {})} />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="arrow-right"
                selected={init_directions['east']}
                onClick={() =>
                  act('init_dir_setting', {
                    dir_flag: 'east',
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="arrow-down"
            selected={init_directions['south']}
            onClick={() =>
              act('init_dir_setting', {
                dir_flag: 'south',
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const RapidPipeDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const { category: rootCategoryIndex } = data;
  return (
    <Window width={550} height={580}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <SelectionSection />
              </Stack.Item>
              {rootCategoryIndex === 0 && (
                <Stack.Item width="90px">
                  <SmartPipeBlockSection />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <PipeTypeSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

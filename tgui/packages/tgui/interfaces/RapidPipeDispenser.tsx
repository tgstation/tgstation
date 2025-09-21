import { useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  ImageButton,
  LabeledList,
  Section,
  Stack,
  StyleableSection,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const ROOT_CATEGORIES = ['Atmospherics', 'Disposals', 'Transit Tubes'] as const;

export const ICON_BY_CATEGORY_NAME = {
  Atmospherics: 'wrench',
  Binary: 'arrows-left-right',
  Devices: 'microchip',
  'Disposal Pipes': 'grip-lines',
  Disposals: 'trash-alt',
  'Heat Exchange': 'thermometer-half',
  Pipes: 'grip-lines',
  'Station Equipment': 'microchip',
  'Transit Tubes': 'bus',
} as const;

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
] as const;

type DirectionsAllowed = {
  east: BooleanLike;
  north: BooleanLike;
  south: BooleanLike;
  west: BooleanLike;
};

type Category = {
  cat_name: string;
  recipes: Recipe[];
};

type Recipe = {
  pipe_index: number;
  pipe_name: string;
  previews: Preview[];
};

type Preview = {
  dir_name: string;
  dir: string;
  flipped: BooleanLike;
  icon_state: string;
  selected: BooleanLike;
};

type Data = {
  // Dynamic
  categories: Category[];
  category: number;
  init_directions: DirectionsAllowed;
  mode: number;
  multi_layer: BooleanLike;
  pipe_layers: number;
  selected_category: string;
  selected_color: string;
  selected_recipe: string;
  // Static
  max_pipe_layers: number;
  paint_colors: Record<string, string>;
};

export function ColorItem(props) {
  const { act, data } = useBackend<Data>();
  const { selected_color, paint_colors = {} } = data;
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
}

function ModeItem(props) {
  const { act, data } = useBackend<Data>();
  const { mode } = data;

  return (
    <LabeledList.Item label="Modes">
      {TOOLS.map((tool) => (
        <Button.Checkbox
          key={tool.bitmask}
          checked={mode & tool.bitmask}
          onClick={() =>
            act('mode', {
              mode: tool.bitmask,
            })
          }
        >
          {tool.name}
        </Button.Checkbox>
      ))}
    </LabeledList.Item>
  );
}

function CategoryItem(props) {
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
}

function SelectionSection(props) {
  const { data } = useBackend<Data>();
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
}

function layerToBitmask(layer: number) {
  return 1 << layer;
}

function LayerSelect(props) {
  const { act, data } = useBackend<Data>();
  const { pipe_layers, multi_layer, max_pipe_layers = 1 } = data;

  return (
    <LabeledList.Item label="Layer">
      {Array.from({ length: max_pipe_layers }).map((_, layer) => (
        <Button.Checkbox
          key={layer}
          checked={
            multi_layer
              ? pipe_layers & layerToBitmask(layer)
              : layerToBitmask(layer) === pipe_layers
          }
          onClick={() =>
            act('pipe_layers', { pipe_layers: layerToBitmask(layer) })
          }
        >
          {layer + 1}
        </Button.Checkbox>
      ))}
      <Button.Checkbox
        key="multilayer"
        checked={multi_layer}
        tooltip="Build on multiple pipe layers simultaneously"
        onClick={() => {
          act('toggle_multi_layer');
        }}
      >
        Multi
      </Button.Checkbox>
    </LabeledList.Item>
  );
}

type RecipeRowProps = {
  recipe: Recipe;
  shownCategory: Category;
};

function RecipeRow(props: RecipeRowProps) {
  const { act } = useBackend<Data>();
  const { recipe, shownCategory } = props;

  return (
    <StyleableSection
      textStyle={{
        color: 'var(--color-label)',
        fontSize: '1em',
        fontWeight: 'normal',
        textAlign: 'right',
      }}
      title={recipe.pipe_name}
      titleStyle={{
        borderBottom: '1px solid var(--color-border)',
        padding: 0,
      }}
    >
      <Stack fill wrap>
        {recipe.previews.map((preview) => (
          <Stack.Item key={preview.dir}>
            <ImageButton
              asset={['pipes32x32', `${preview.dir}-${preview.icon_state}`]}
              color="blue"
              imageSize={58}
              assetSize={30}
              onClick={() => {
                act('pipe_type', {
                  pipe_type: recipe.pipe_index,
                  category: shownCategory.cat_name,
                });
                act('setdir', {
                  dir: preview.dir,
                  flipped: preview.flipped,
                });
              }}
              selected={preview.selected}
              tooltip={preview.dir_name}
              tooltipPosition="bottom"
            />
          </Stack.Item>
        ))}
      </Stack>
    </StyleableSection>
  );
}

function PipeTypeSection(props) {
  const { data } = useBackend<Data>();
  const { categories = [], selected_category } = data;
  const [categoryName, setCategoryName] = useState(selected_category);

  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];

  return (
    <Stack fill vertical>
      <Tabs mb={-1}>
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
      <Section fill scrollable>
        {shownCategory?.recipes.map((recipe) => (
          <RecipeRow
            key={recipe.pipe_name}
            recipe={recipe}
            shownCategory={shownCategory}
          />
        ))}
      </Section>
    </Stack>
  );
}

export function SmartPipeBlockSection(props) {
  const { act, data } = useBackend<Data>();
  const { init_directions } = data;

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
                selected={init_directions.north}
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
                selected={init_directions.west}
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
                selected={init_directions.east}
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
            selected={init_directions.south}
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
}

export function RapidPipeDispenser(props) {
  const { data } = useBackend<Data>();
  const { category: rootCategoryIndex } = data;

  return (
    <Window width={550} height={580}>
      <Window.Content>
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
}

import { classes } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, ColorBox, LabeledList, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

const ROOT_CATEGORIES = ['Atmospherics', 'Disposals', 'Transit Tubes'];

export const ICON_BY_CATEGORY_NAME = {
  'Atmospherics': 'wrench',
  'Disposals': 'trash-alt',
  'Transit Tubes': 'bus',
  'Pipes': 'grip-lines',
  'Disposal Pipes': 'grip-lines',
  'Devices': 'microchip',
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

export const ColorItem = (props, context) => {
  const { act, data } = useBackend(context);
  const { selected_color } = data;
  return (
    <LabeledList.Item label="Color">
      <Box inline width="64px" color={data.paint_colors[selected_color]}>
        {selected_color}
      </Box>
      {Object.keys(data.paint_colors).map((colorName) => (
        <ColorBox
          key={colorName}
          ml={1}
          color={data.paint_colors[colorName]}
          onClick={() =>
            act('color', {
              paint_color: colorName,
            })
          }
        />
      ))}
    </LabeledList.Item>
  );
};

const ModeItem = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode } = data;
  return (
    <LabeledList.Item label="Modes">
      <Stack fill>
        {TOOLS.map((tool) => (
          <Stack.Item grow key={tool.bitmask}>
            <Button.Checkbox
              checked={mode & tool.bitmask}
              fluid
              content={tool.name}
              onClick={() =>
                act('mode', {
                  mode: tool.bitmask,
                })
              }
            />
          </Stack.Item>
        ))}
      </Stack>
    </LabeledList.Item>
  );
};

const CategoryItem = (props, context) => {
  const { act, data } = useBackend(context);
  const { category: rootCategoryIndex } = data;
  return (
    <LabeledList.Item label="Category">
      {ROOT_CATEGORIES.map((categoryName, i) => (
        <Button
          key={categoryName}
          selected={rootCategoryIndex === i}
          icon={ICON_BY_CATEGORY_NAME[categoryName]}
          color="transparent"
          onClick={() => act('category', { category: i })}>
          {categoryName}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

const SelectionSection = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section>
      <LabeledList>
        <CategoryItem />
        <ModeItem />
        <ColorItem />
      </LabeledList>
    </Section>
  );
};

export const LayerSelect = (props, context) => {
  const { act, data } = useBackend(context);
  const { piping_layer } = data;
  return (
    <Stack vertical mb={1}>
      {[1, 2, 3, 4, 5].map((layer) => (
        <Stack.Item my={0} key={layer}>
          <Button.Checkbox
            checked={layer === piping_layer}
            content={'Layer ' + layer}
            onClick={() =>
              act('piping_layer', {
                piping_layer: layer,
              })
            }
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const PreviewSelect = (props, context) => {
  const { act, data } = useBackend(context);
  const { category: rootCategoryIndex } = data;
  const previews = data.preview_rows.flatMap((row) => row.previews);
  return (
    <Box width="120px">
      {previews.map((preview) => (
        <Button
          ml={0}
          key={preview.dir}
          title={preview.dir_name}
          selected={preview.selected}
          style={{
            width: '40px',
            height: '40px',
            padding: 0,
          }}
          onClick={() =>
            act('setdir', {
              dir: preview.dir,
              flipped: preview.flipped,
            })
          }>
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

const LayerSection = (props, context) => {
  const { act, data } = useBackend(context);
  const { category: rootCategoryIndex, piping_layer } = data;
  const previews = data.preview_rows.flatMap((row) => row.previews);
  return (
    <Section fill width={7.5}>
      {rootCategoryIndex === 0 && <LayerSelect />}
      <PreviewSelect />
    </Section>
  );
};

const PipeTypeSection = (props, context) => {
  const { act, data } = useBackend(context);
  const { categories = [] } = data;
  const [categoryName, setCategoryName] = useLocalState(
    context,
    'categoryName'
  );
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];
  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category, i) => (
          <Tabs.Tab
            fluid
            key={category.cat_name}
            icon={ICON_BY_CATEGORY_NAME[category.cat_name]}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}>
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map((recipe) => (
        <Button.Checkbox
          key={recipe.pipe_index}
          fluid
          ellipsis
          checked={recipe.selected}
          content={recipe.pipe_name}
          title={recipe.pipe_name}
          onClick={() =>
            act('pipe_type', {
              pipe_type: recipe.pipe_index,
              category: shownCategory.cat_name,
            })
          }
        />
      ))}
    </Section>
  );
};

export const SmartPipeBlockSection = (props, context) => {
  const { act, data } = useBackend(context);
  const init_directions = data.init_directions || [];
  const { category: rootCategoryIndex } = data;
  return (
    <Section height={7.5}>
      <Stack fill vertical textAlign="center">
        <Stack.Item basis={1.5}>
          <Stack>
            <Stack.Item>
              <Button
                color="transparent"
                icon="info"
                tooltipPosition="right"
                tooltip={multiline`
                This is a panel for blocking certain connection
                directions for the smart pipes.
                The button in the center resets to
                default (all directions can connect)`}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="arrow-up"
                disabled={!!data.smart_pipe}
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
        <Stack.Item basis={1.5}>
          <Stack fill>
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
            <Stack.Item grow>
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
        <Stack.Item grow>
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

export const RapidPipeDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const { category: rootCategoryIndex } = data;
  return (
    <Window width={450} height={575}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <SelectionSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <Stack vertical fill>
                  {rootCategoryIndex === 0 && (
                    <Stack.Item>
                      <SmartPipeBlockSection />
                    </Stack.Item>
                  )}
                  <Stack.Item grow>
                    <LayerSection />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <PipeTypeSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

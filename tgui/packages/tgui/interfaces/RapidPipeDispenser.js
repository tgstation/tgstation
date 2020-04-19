import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, ColorBox, Flex, LabeledList, Section, Tabs } from '../components';
import { Window } from '../layouts';

const ROOT_CATEGORIES = [
  'Atmospherics',
  'Disposals',
  'Transit Tubes',
];

const ICON_BY_CATEGORY_NAME = {
  'Atmospherics': 'wrench',
  'Disposals': 'trash-alt',
  'Transit Tubes': 'bus',
  'Pipes': 'grip-lines',
  'Disposal Pipes': 'grip-lines',
  'Devices': 'microchip',
  'Heat Exchange': 'thermometer-half',
  'Station Equipment': 'microchip',
};

const PAINT_COLORS = {
  grey: '#bbbbbb',
  amethyst: '#a365ff',
  blue: '#4466ff',
  brown: '#b26438',
  cyan: '#48eae8',
  dark: '#808080',
  green: '#1edd00',
  orange: '#ffa030',
  purple: '#b535ea',
  red: '#ff3333',
  violet: '#6e00f6',
  yellow: '#ffce26',
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
    name: 'Paint',
    bitmask: 8,
  },
];

export const RapidPipeDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    category: rootCategoryIndex,
    categories = [],
    selected_color,
    piping_layer,
    mode,
  } = data;
  const previews = data.preview_rows.flatMap(row => row.previews);
  const [
    categoryName,
    setCategoryName,
  ] = useLocalState(context, 'categoryName');
  const shownCategory = categories
    .find(category => category.cat_name === categoryName)
    || categories[0];
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Category">
              {ROOT_CATEGORIES.map((categoryName, i) => (
                <Button
                  key={categoryName}
                  selected={rootCategoryIndex === i}
                  icon={ICON_BY_CATEGORY_NAME[categoryName]}
                  color="transparent"
                  content={categoryName}
                  onClick={() => act('category', { category: i })} />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Modes">
              {TOOLS.map(tool => (
                <Button.Checkbox
                  key={tool.bitmask}
                  checked={mode & tool.bitmask}
                  content={tool.name}
                  onClick={() => act('mode', {
                    mode: tool.bitmask,
                  })} />
              ))}
            </LabeledList.Item>
            <LabeledList.Item
              label="Color">
              <Box
                inline
                width="64px"
                color={PAINT_COLORS[selected_color]}>
                {selected_color}
              </Box>
              {Object.keys(PAINT_COLORS)
                .map(colorName => (
                  <ColorBox
                    key={colorName}
                    ml={1}
                    color={PAINT_COLORS[colorName]}
                    onClick={() => act('color', {
                      paint_color: colorName,
                    })} />
                ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Flex m={-0.5}>
          <Flex.Item m={0.5}>
            <Section>
              {rootCategoryIndex === 0 && (
                <Box mb={1}>
                  {[1, 2, 3].map(layer => (
                    <Button.Checkbox
                      key={layer}
                      fluid
                      checked={layer === piping_layer}
                      content={'Layer ' + layer}
                      onClick={() => act('piping_layer', {
                        piping_layer: layer,
                      })} />
                  ))}
                </Box>
              )}
              <Box width="108px">
                {previews.map(preview => (
                  <Button
                    key={preview.dir}
                    title={preview.dir_name}
                    selected={preview.selected}
                    style={{
                      width: '48px',
                      height: '48px',
                      padding: 0,
                    }}
                    onClick={() => act('setdir', {
                      dir: preview.dir,
                      flipped: preview.flipped,
                    })}>
                    <Box
                      className={classes([
                        'pipes32x32',
                        preview.dir + '-' + preview.icon_state,
                      ])}
                      style={{
                        transform: 'scale(1.5) translate(17%, 17%)',
                      }} />
                  </Button>
                ))}
              </Box>
            </Section>
          </Flex.Item>
          <Flex.Item m={0.5} grow={1}>
            <Section>
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
              {shownCategory?.recipes.map(recipe => (
                <Button.Checkbox
                  key={recipe.pipe_index}
                  fluid
                  ellipsis
                  checked={recipe.selected}
                  content={recipe.pipe_name}
                  title={recipe.pipe_name}
                  onClick={() => act('pipe_type', {
                    pipe_type: recipe.pipe_index,
                    category: shownCategory.cat_name,
                  })} />
              ))}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

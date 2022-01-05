import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, ColorBox, LabeledList, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

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

const ColorSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selected_color,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item
          label="Color">
          <Box
            inline
            width="64px"
            color={data.paint_colors[selected_color]}>
            {selected_color}
          </Box>
          {Object.keys(data.paint_colors)
            .map(colorName => (
              <ColorBox
                key={colorName}
                ml={1}
                color={data.paint_colors[colorName]}
                onClick={() => act('color', {
                  paint_color: colorName,
                })} />
            ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const LayerSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    piping_layer,
  } = data;
  return (
    <Section fill width={7.5}>
      <Stack vertical mb={1}>
        {[1, 2, 3, 4, 5].map(layer => (
          <Stack.Item my={0} key={layer}>
            <Button.Checkbox
              checked={layer === piping_layer}
              content={'Layer ' + layer}
              onClick={() => act('piping_layer', {
                piping_layer: layer,
              })} />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const PipeTypeSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories = [],
  } = data;
  const [
    categoryName,
    setCategoryName,
  ] = useLocalState(context, 'categoryName');
  const shownCategory = categories
    .find(category => category.cat_name === categoryName)
    || categories[0];
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
      {shownCategory?.recipes.map(recipe => (
        <Button
          key={recipe.pipe_index}
          fluid
          ellipsis
          content={recipe.pipe_name}
          title={recipe.pipe_name}
          onClick={() => act('pipe_type', {
            pipe_type: recipe.pipe_index,
            pipe_dir: recipe.dir,
            category: shownCategory.cat_name,
          })} />
      ))}
    </Section>
  );
};

const SmartPipeBlockSection = (props, context) => {
  const { act, data } = useBackend(context);
  const init_directions = data.init_directions || [];
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
                default (all directions can connect)`} />
            </Stack.Item>
            <Stack.Item>
              <Button icon="arrow-up"
                disabled={!!data.smart_pipe}
                selected={init_directions["north"]}
                onClick={() => act('init_dir_setting', {
                  dir_flag: "north",
                })} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item basis={1.5}>
          <Stack fill>
            <Stack.Item>
              <Button icon="arrow-left"
                selected={init_directions["west"]}
                onClick={() => act('init_dir_setting', {
                  dir_flag: "west",
                })} />
            </Stack.Item>
            <Stack.Item grow>
              <Button icon="circle"
                onClick={() => act('init_reset', {
                })} />
            </Stack.Item>
            <Stack.Item>
              <Button icon="arrow-right"
                selected={init_directions["east"]}
                onClick={() => act('init_dir_setting', {
                  dir_flag: "east",
                })} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Button icon="arrow-down"
            selected={init_directions["south"]}
            onClick={() => act('init_dir_setting', {
              dir_flag: "south",
            })} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const PipeDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    category: rootCategoryIndex,
  } = data;
  return (
    <Window
      width={450}
      height={575}>
      <Window.Content>
        <Stack fill vertical>
          {rootCategoryIndex === 0 && (
            <Stack.Item>
              <ColorSection />
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Stack fill>
              {rootCategoryIndex === 0 && (
                <Stack.Item>
                  <Stack vertical fill>
                    <Stack.Item>
                      <SmartPipeBlockSection />
                    </Stack.Item>
                    <Stack.Item grow>
                      <LayerSection />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              )}
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

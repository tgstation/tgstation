import { classes } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Tabs, Stack } from '../components';
import { InfoSection } from './RapidConstructionDevice';
import { Window } from '../layouts';

type Data = {
  selected_icon: string;
  tile_dirs: string[];
  selected_dir: string;
  selected_category: string;
  selected_recipe: string;
  categories: Category[];
};

type Category = {
  cat_name: string;
  recipes: Design[];
};

type Design = {
  index: number;
  name: string;
  icon: string;
};

const TilePreview = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { selected_icon } = data;
  return (
    <Section
      backgroundColor="green"
      style={{
        width: '50px',
        height: '50px',
      }}>
      <Box
        className={classes(['rtd-tgui32x32', selected_icon])}
        style={{
          transform: 'scale(1.5) translate(9.5%, 9.5%)',
        }}
      />
    </Section>
  );
};

const DirectionSelect = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { tile_dirs = [], selected_dir } = data;
  return (
    <Section fill vertical>
      <Stack vertical>
        {tile_dirs.map((dir) => (
          <Stack.Item key={dir}>
            <Button.Checkbox
              content={dir}
              color="transparent"
              checked={dir === selected_dir}
              onClick={() =>
                act('set_dir', {
                  dir: dir,
                })
              }
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const TileRotateSection = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { selected_dir } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <TilePreview />
      </Stack.Item>
      <Stack.Item grow>
        {selected_dir !== null ? <DirectionSelect /> : ''}
      </Stack.Item>
    </Stack>
  );
};

const TileDesignSection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { categories = [], selected_category, selected_recipe } = data;
  const [categoryName, setCategoryName] = useLocalState(
    context,
    'categoryName',
    selected_category
  );
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];
  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            fluid
            key={category.cat_name}
            selected={category.cat_name === categoryName}
            onClick={() => setCategoryName(category.cat_name)}>
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map((recipe) => (
        <Button
          key={recipe.index}
          fluid
          ellipsis
          color="transparent"
          selected={
            recipe.name === selected_recipe &&
            shownCategory.cat_name === selected_category
          }
          style={{
            height: '35px',
          }}
          onClick={() =>
            act('recipe', {
              cat_name: shownCategory.cat_name,
              id: recipe.index,
            })
          }>
          <Box
            inline
            verticalAlign="middle"
            mr="20px"
            className={classes(['rtd-tgui32x32', recipe.icon])}
            style={{
              transform: 'scale(1.2) translate(9.5%, 9.5%)',
            }}
          />
          <span>{capitalizeAll(recipe.name)}</span>
        </Button>
      ))}
    </Section>
  );
};

export const RapidTilingDevice = (props, context) => {
  return (
    <Window width={500} height={540}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <InfoSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <TileRotateSection />
              </Stack.Item>
              <Stack.Item grow>
                <TileDesignSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
